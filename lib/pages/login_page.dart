import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../storage/local_auth_storage.dart';
import 'main_shell_page.dart';

enum _AuthMode { passwordLogin, register, resetPassword }

class _SmsCode {
  _SmsCode({required this.value, required this.expireAt});

  final String value;
  final DateTime expireAt;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  final TextEditingController _regPhoneCtrl = TextEditingController();
  final TextEditingController _regPwdCtrl = TextEditingController();
  final TextEditingController _regConfirmPwdCtrl = TextEditingController();
  final TextEditingController _resetPhoneCtrl = TextEditingController();
  final TextEditingController _resetCodeCtrl = TextEditingController();
  final TextEditingController _resetPwdCtrl = TextEditingController();
  final TextEditingController _resetConfirmPwdCtrl = TextEditingController();

  final Random _random = Random.secure();
  final Map<String, _SmsCode> _smsCodes = <String, _SmsCode>{};
  final Map<String, int> _sendCooldown = <String, int>{};

  Timer? _timer;
  _AuthMode _mode = _AuthMode.passwordLogin;
  bool _agreeProtocol = true;
  bool _obscurePwd = true;
  bool _obscureRegPwd = true;
  bool _obscureRegConfirmPwd = true;
  bool _obscureResetPwd = true;
  bool _obscureResetConfirmPwd = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_sendCooldown.isEmpty) return;
      setState(() {
        final List<String> keys = _sendCooldown.keys.toList();
        for (final String key in keys) {
          final int remain = (_sendCooldown[key] ?? 0) - 1;
          if (remain <= 0) {
            _sendCooldown.remove(key);
          } else {
            _sendCooldown[key] = remain;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPwdCtrl.dispose();
    _regConfirmPwdCtrl.dispose();
    _resetPhoneCtrl.dispose();
    _resetCodeCtrl.dispose();
    _resetPwdCtrl.dispose();
    _resetConfirmPwdCtrl.dispose();
    super.dispose();
  }

  bool _isValidPhone(String value) {
    final RegExp reg = RegExp(r'^1\d{10}$');
    return reg.hasMatch(value);
  }

  String _smsKey(String scene, String phone) => '$scene:$phone';

  void _goMainPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShellPage()),
    );
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _sendCode({
    required String scene,
    required TextEditingController phoneCtrl,
  }) async {
    final String phone = phoneCtrl.text.trim();
    if (!_isValidPhone(phone)) {
      _toast('请输入正确手机号');
      return;
    }
    final String cooldownKey = _smsKey(scene, phone);
    if ((_sendCooldown[cooldownKey] ?? 0) > 0) return;

    final bool exists = await LocalAuthStorage.userExists(phone);
    if (!exists) {
      _toast('该手机号尚未注册');
      return;
    }

    final String code = (100000 + _random.nextInt(900000)).toString();
    _smsCodes[cooldownKey] = _SmsCode(
      value: code,
      expireAt: DateTime.now().add(const Duration(minutes: 5)),
    );
    setState(() {
      _sendCooldown[cooldownKey] = 60;
    });
    _toast('本地验证码：$code（5分钟内有效）');
  }

  bool _verifyCode({
    required String scene,
    required String phone,
    required String code,
  }) {
    final _SmsCode? data = _smsCodes[_smsKey(scene, phone)];
    if (data == null) return false;
    if (DateTime.now().isAfter(data.expireAt)) return false;
    return data.value == code;
  }

  Future<void> _loginWithPassword() async {
    final String phone = _phoneCtrl.text.trim();
    final String password = _pwdCtrl.text;
    if (!_agreeProtocol) {
      _toast('请先阅读并同意服务协议');
      return;
    }
    if (!_isValidPhone(phone)) {
      _toast('请输入正确手机号');
      return;
    }
    if (password.isEmpty) {
      _toast('请输入密码');
      return;
    }
    final bool ok = await LocalAuthStorage.verifyPassword(
      phone: phone,
      password: password,
    );
    if (!ok) {
      _toast('手机号或密码错误');
      return;
    }
    await LocalAuthStorage.saveLoginSession(phone);
    _goMainPage();
  }

  Future<void> _register() async {
    final String phone = _regPhoneCtrl.text.trim();
    final String password = _regPwdCtrl.text;
    final String confirm = _regConfirmPwdCtrl.text;
    if (!_agreeProtocol) {
      _toast('请先阅读并同意服务协议');
      return;
    }
    if (!_isValidPhone(phone)) {
      _toast('请输入正确手机号');
      return;
    }
    if (password.length < 6) {
      _toast('密码长度至少6位');
      return;
    }
    if (password != confirm) {
      _toast('两次密码输入不一致');
      return;
    }
    final bool ok = await LocalAuthStorage.registerUser(
      phone: phone,
      password: password,
    );
    if (!ok) {
      _toast('该手机号已注册');
      return;
    }
    _phoneCtrl.text = phone;
    _pwdCtrl.clear();
    setState(() {
      _mode = _AuthMode.passwordLogin;
    });
    _toast('注册成功，请登录');
  }

  Future<void> _resetPassword() async {
    final String phone = _resetPhoneCtrl.text.trim();
    final String code = _resetCodeCtrl.text.trim();
    final String password = _resetPwdCtrl.text;
    final String confirm = _resetConfirmPwdCtrl.text;

    if (!_isValidPhone(phone)) {
      _toast('请输入正确手机号');
      return;
    }
    if (code.length != 6) {
      _toast('请输入6位验证码');
      return;
    }
    if (password.length < 6) {
      _toast('新密码长度至少6位');
      return;
    }
    if (password != confirm) {
      _toast('两次密码输入不一致');
      return;
    }
    if (!_verifyCode(scene: 'reset', phone: phone, code: code)) {
      _toast('验证码错误或已过期');
      return;
    }

    final bool ok = await LocalAuthStorage.resetPassword(
      phone: phone,
      newPassword: password,
    );
    if (!ok) {
      _toast('该手机号尚未注册');
      return;
    }
    _phoneCtrl.text = phone;
    _pwdCtrl.clear();
    _resetCodeCtrl.clear();
    _resetPwdCtrl.clear();
    _resetConfirmPwdCtrl.clear();
    setState(() {
      _mode = _AuthMode.passwordLogin;
    });
    _toast('密码重置成功，请重新登录');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/login_background_top.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 220),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildModeTabs(),
                    const SizedBox(height: 18),
                    if (_mode == _AuthMode.passwordLogin) _buildPasswordLogin(),
                    if (_mode == _AuthMode.register) _buildRegister(),
                    if (_mode == _AuthMode.resetPassword) _buildResetPassword(),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _agreeProtocol,
                          activeColor: const Color(0xFF5A8FFF),
                          visualDensity: VisualDensity.compact,
                          onChanged: (bool? value) {
                            setState(() {
                              _agreeProtocol = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: '我已阅读并同意 ',
                              style: TextStyle(
                                color: Color(0xFF8A93A6),
                                fontSize: 13,
                              ),
                              children: <InlineSpan>[
                                TextSpan(
                                  text: '《用户服务协议》',
                                  style: TextStyle(color: Color(0xFF5A8FFF)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs() {
    Widget tab(String text, _AuthMode mode) {
      final bool active = _mode == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _mode = mode;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFEFF4FF) : const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active
                    ? const Color(0xFF4C84FF)
                    : const Color(0xFF8E95A5),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: <Widget>[
        tab('密码登录', _AuthMode.passwordLogin),
        const SizedBox(width: 8),
        tab('手机注册', _AuthMode.register),
      ],
    );
  }

  Widget _buildPasswordLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildInput(
          controller: _phoneCtrl,
          hint: '请输入手机号',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildInput(
          controller: _pwdCtrl,
          hint: '请输入密码',
          obscureText: _obscurePwd,
          suffix: IconButton(
            onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
            icon: Icon(
              _obscurePwd
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9198A8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton(text: '登录', onPressed: _loginWithPassword),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _mode = _AuthMode.resetPassword;
                _resetPhoneCtrl.text = _phoneCtrl.text.trim();
              });
            },
            child: const Text(
              '忘记密码?',
              style: TextStyle(color: Color(0xFF4C84FF)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegister() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildInput(
          controller: _regPhoneCtrl,
          hint: '请输入手机号',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildInput(
          controller: _regPwdCtrl,
          hint: '请设置密码（至少6位）',
          obscureText: _obscureRegPwd,
          suffix: IconButton(
            onPressed: () => setState(() => _obscureRegPwd = !_obscureRegPwd),
            icon: Icon(
              _obscureRegPwd
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9198A8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildInput(
          controller: _regConfirmPwdCtrl,
          hint: '请再次输入密码',
          obscureText: _obscureRegConfirmPwd,
          suffix: IconButton(
            onPressed: () =>
                setState(() => _obscureRegConfirmPwd = !_obscureRegConfirmPwd),
            icon: Icon(
              _obscureRegConfirmPwd
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9198A8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton(text: '注册', onPressed: _register),
      ],
    );
  }

  Widget _buildResetPassword() {
    final String phone = _resetPhoneCtrl.text.trim();
    final int remain = _sendCooldown[_smsKey('reset', phone)] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          '忘记密码 - 验证码重置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B3240),
          ),
        ),
        const SizedBox(height: 12),
        _buildInput(
          controller: _resetPhoneCtrl,
          hint: '请输入手机号',
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _buildCodeInput(
          controller: _resetCodeCtrl,
          hint: '请输入验证码',
          btnText: remain > 0 ? '${remain}s' : '发送验证码',
          onTapSend: remain > 0
              ? null
              : () => _sendCode(scene: 'reset', phoneCtrl: _resetPhoneCtrl),
        ),
        const SizedBox(height: 12),
        _buildInput(
          controller: _resetPwdCtrl,
          hint: '请输入新密码',
          obscureText: _obscureResetPwd,
          suffix: IconButton(
            onPressed: () =>
                setState(() => _obscureResetPwd = !_obscureResetPwd),
            icon: Icon(
              _obscureResetPwd
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9198A8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildInput(
          controller: _resetConfirmPwdCtrl,
          hint: '请再次输入新密码',
          obscureText: _obscureResetConfirmPwd,
          suffix: IconButton(
            onPressed: () => setState(
              () => _obscureResetConfirmPwd = !_obscureResetConfirmPwd,
            ),
            icon: Icon(
              _obscureResetConfirmPwd
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9198A8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPrimaryButton(text: '重置密码', onPressed: _resetPassword),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _mode = _AuthMode.passwordLogin;
              });
            },
            child: const Text(
              '返回登录',
              style: TextStyle(color: Color(0xFF4C84FF)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC2C8D5), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFF5F7FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 16, color: Color(0xFF2B3240)),
    );
  }

  Widget _buildCodeInput({
    required TextEditingController controller,
    required String hint,
    required String btnText,
    required VoidCallback? onTapSend,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC2C8D5), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFF5F7FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        suffixIcon: TextButton(
          onPressed: onTapSend,
          child: Text(btnText, style: const TextStyle(fontSize: 13)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 16, color: Color(0xFF2B3240)),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required Future<void> Function() onPressed,
  }) {
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF6B8AFF), Color(0xFF4DA0FF)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ElevatedButton(
          onPressed: () => unawaited(onPressed()),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
