import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await saveFormDataToDatabase();
      await saveFormDataToGoogleSheet();
      _formKey.currentState!.reset();
    }
  }

  Future<void> saveFormDataToDatabase() async {
    //  HTTP request to your database API and pass the form data
    final response = await http.post(
      Uri.parse('https://your-api-endpoint.com/save-data'),
      body: {
        'name': _nameController.text,
        'email': _emailController.text,
      },
    );

    if (response.statusCode == 200) {
      print('Data saved to the database');
    } else {
      print('Error saving data to the database');
    }
  }

  Future<void> saveFormDataToGoogleSheet() async {
    var sheets;
    final client = await sheets.sheetsApi;
    var googleSignInAccount;
    final credentials = await googleSignInAccount.authentication;

    final headers = await client.authHeaders;
    final sheetsApi = sheets.SheetsApi(client);

    // Get the spreadsheet ID and range
    const spreadsheetId = 'your-spreadsheet-id';
    const range = 'Sheet1!A1:B1';

    final values = sheets.ValueRange.fromJson({
      'values': [
        [_nameController.text, _emailController.text],
      ],
    });

    try {
      await sheetsApi.spreadsheets.values.append(
        values,
        spreadsheetId,
        range,
        valueInputOption: 'RAW',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      // Error to Google Sheets
      print('Error saving data to Google Sheets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: const Drawer(),
      appBar: AppBar(
        title: const Text(
          'Form App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade400,
        actions: const [
          Icon(
            Icons.settings,
            size: 27,
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 250),
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      prefixIcon: Icon(Icons.mail),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text(
                      'Submit',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
