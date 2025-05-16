import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/passcode_view_model.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({Key? key}) : super(key: key);

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _LnameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _LnameController.dispose();
    _mobileController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<PasscodeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    const Icon(
                      Icons.lock_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    if (!viewModel.isRegistered) ...[
                      _buildRegistrationForm(viewModel),
                    ] else ...[
                      Text(
                    'Welcome Back, ${viewModel.currentUser?.name ?? ''} ${viewModel.currentUser?.Lname ?? ''}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter Your Passcode',
                        style: TextStyle(
                          fontSize: 16,
                          color: viewModel.isError ? Colors.red : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPasscodeInput(viewModel),
                      if (viewModel.isError && viewModel.errorMessage != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () => _showResetConfirmation(context, viewModel),
                        child: const Text(
                          'Forgot Passcode?',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showResetConfirmation(BuildContext context, PasscodeViewModel viewModel) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Reset Passcode',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove your account. You will need to register again. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await viewModel.resetPasscode();
    }
  }

  Widget _buildRegistrationForm(PasscodeViewModel viewModel) {
    return Column(
      children: [
        const Text(
          'Create Your Account',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _LnameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Last Name',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _mobileController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passcodeController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Create 4-Digit Passcode',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        if (viewModel.isError && viewModel.errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            viewModel.errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => _handleRegistration(viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Register',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasscodeInput(PasscodeViewModel viewModel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.all(8),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < viewModel.enteredPasscode.length
                    ? Colors.white
                    : Colors.white24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3/2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            if (index == 9) {
              return const SizedBox.shrink();
            }
            if (index == 10) {
              return _buildKeypadButton('0', viewModel);
            }
            if (index == 11) {
              return _buildDeleteButton(viewModel);
            }
            return _buildKeypadButton('${index + 1}', viewModel);
          },
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String number, PasscodeViewModel viewModel) {
    return TextButton(
      onPressed: () => _onKeyPressed(number, viewModel),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.white10,
      ),
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(PasscodeViewModel viewModel) {
    return TextButton(
      onPressed: viewModel.deleteLastDigit,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.white10,
      ),
      child: const Icon(
        Icons.backspace_outlined,
        color: Colors.white,
      ),
    );
  }

  Future<void> _handleRegistration(PasscodeViewModel viewModel) async {
    final success = await viewModel.registerUser(
      _nameController.text,
      _LnameController.text,
      _mobileController.text,
      _passcodeController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _onKeyPressed(String digit, PasscodeViewModel viewModel) async {
    viewModel.updateEnteredPasscode(digit);
    
    if (viewModel.isPasscodeComplete) {
      final success = await viewModel.verifyPasscode(viewModel.enteredPasscode);
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        viewModel.clearPasscode();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Incorrect passcode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 