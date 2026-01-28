import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'student_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _selectedDob;

  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Student Sign Up' : 'Student Login'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.jpg',
                  height: 120,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    hintText: 'e.g., D23IT123',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Please enter Student ID' : null,
                ),
                const SizedBox(height: 16),
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'College Email ID',
                      hintText: 'e.g., d23it123@charusat.edu.in',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16),
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) return 'Please enter Email';
                      if (!value!.toLowerCase().endsWith('@charusat.edu.in')) {
                        return 'Only @charusat.edu.in emails allowed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDob == null
                            ? 'Select Date of Birth'
                            : '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDob == null ? Colors.grey.shade600 : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  if (_selectedDob == null && _formKey.currentState?.validate() == false) // Simple check hint
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12),
                      child: Text(
                        'Please select Date of Birth',
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                      ),
                    ),
                ] else ...[
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (DDMMYYYY)',
                      hintText: 'e.g., 25012005',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter Date of Birth as Password' : null,
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuthAction,
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isSignUp ? 'Sign Up' : 'Login'),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _formKey.currentState?.reset();
                      _selectedDob = null;
                      _passwordController.clear();
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Login'
                        : "Don't have an account? Sign Up",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _handleAuthAction() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    // Additional validation for Sign Up
    if (_isSignUp && _selectedDob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Date of Birth'), backgroundColor: Colors.red),
        );
        return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await AuthService.instance.signUp(
          email: _emailController.text,
          dob: _selectedDob!,
          studentId: _studentIdController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign Up Successful! Please check your email for confirmation.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
              _isSignUp = false;
              _formKey.currentState?.reset();
              _selectedDob = null;
          });
        }
      } else {
        await AuthService.instance.signIn(
          studentId: _studentIdController.text,
          password: _passwordController.text,
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDashboardScreen(
                studentId: _studentIdController.text.toUpperCase(),
              ),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

