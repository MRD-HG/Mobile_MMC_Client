// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _gender = '';
  String _city = '';
Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    Map<String, String> requestBody = {
      'firstName': _firstName,
      'lastName': _lastName,
      'email': _email,
      'phone': _phone,
      'gender': _gender,
      'city': _city,
    };

   
    String requestBodyJson = jsonEncode(requestBody);

    // Send POST request
    try {
      var response = await http.post(
        Uri.parse('https://littletankayak18.conveyor.cloud/gateway/Participant'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBodyJson, 
      );

      
      if (response.statusCode == 200) {
        print('Registration successful!');
        print(response.body);
      } else {
        // Handle error response
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Failed to submit form: $e');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[600],
        title: Text('Register',style:TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(

          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                
                    border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)))
                    ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _firstName = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                
                    labelText: 'Last Name'),
                  
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _lastName = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    
                    border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    
                    labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                 
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    
                    border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    labelText: 'Phone'
                  ,
                  
                  
                  ),
                
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                   
                    return null;
                  },
                  onSaved: (value) {
                    _phone = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    
                    labelText: 'Gender',
                  // border: OutlineInputBorder(borderSide: BorderSide(width: 1)), 
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your gender';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _gender = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border:OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    
                    labelText: 'City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _city = value!;
                  },
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:MaterialStatePropertyAll( Colors.blue[600]),
                    fixedSize: MaterialStatePropertyAll(Size(MediaQuery.of(context).size.width *0.8,MediaQuery.of(context).size.height *0.07)),
                    
                  ),
                  onPressed: _submitForm,
                  child: Text('Submit',style:TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(


    home: RegisterForm(),
  ));
}
