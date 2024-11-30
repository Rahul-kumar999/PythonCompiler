import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(PythonCompilerApp());
}

class PythonCompilerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Compiler',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: PythonCompilerScreen(),
    );
  }
}

class PythonCompilerScreen extends StatefulWidget {
  @override
  _PythonCompilerScreenState createState() => _PythonCompilerScreenState();
}

class _PythonCompilerScreenState extends State<PythonCompilerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String _output = "";
  bool _isLoading = false;

  late TabController _tabController; // Declare the TabController

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Initialize TabController
  }

  Future<void> _runCode() async {
    setState(() {
      _isLoading = true;
      _output = "";
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/execute'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"code": _controller.text}),
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        _output = jsonDecode(response.body)["output"];
        _tabController.animateTo(1); // Switch to the Output tab
      } else {
        _output = "Error: Failed to connect to server.";
        _tabController.animateTo(1); // Switch to Output tab on error too
      }
    });
  }

  void _clearFields() {
    setState(() {
      _controller.clear();
      _output = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Python Compiler'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController, // Assign TabController to TabBar
          tabs: [
            Tab(text: 'Python'),
            Tab(text: 'Output'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Assign TabController to TabBarView
        children: [
          // Code Editor Screen
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Line Numbers Column
                    Container(
                      width: 30,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.black54,
                      child: ListView.builder(
                        controller: ScrollController(),
                        itemCount: _controller.text.split('\n').length + 1,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    // Code Editor Column
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Write Python code here...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8),
                          filled: true,
                          fillColor: Colors.grey[800],
                        ),
                        onChanged: (text) {
                          setState(() {}); // Update line numbers on text change
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Run and Clear Buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _runCode,
                        child: Text(_isLoading ? 'Running...' : 'Run Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade400,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _clearFields,
                      child: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Output Screen with decoration
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade400], // Gradient background
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // Shadow color
                    blurRadius: 8,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
                border: Border.all(
                  color: Colors.tealAccent, // Border color
                  width: 2,
                ),
              ),
              child: Text(
                _output,
                style: TextStyle(
                  color: Colors.white, // Output text color
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of TabController
    super.dispose();
  }
}
