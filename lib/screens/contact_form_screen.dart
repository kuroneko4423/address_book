import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../database/database_helper.dart';
import '../services/postal_code_service.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  const ContactFormScreen({super.key, this.contact});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _postalCodeController;
  late TextEditingController _addressController;
  late TextEditingController _companyController;
  late TextEditingController _notesController;

  bool _isLoading = false;
  bool _isSearchingPostalCode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _postalCodeController = TextEditingController(text: widget.contact?.postalCode ?? '');
    _addressController = TextEditingController(text: widget.contact?.address ?? '');
    _companyController = TextEditingController(text: widget.contact?.company ?? '');
    _notesController = TextEditingController(text: widget.contact?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _postalCodeController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.contact != null;

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final contact = Contact(
        id: widget.contact?.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.contact?.createdAt,
      );

      if (_isEditing) {
        await _databaseHelper.updateContact(contact);
      } else {
        await _databaseHelper.insertContact(contact);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '連絡先を更新しました' : '連絡先を追加しました'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchPostalCode() async {
    final postalCode = _postalCodeController.text.trim();
    
    if (!PostalCodeService.isValidPostalCode(postalCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正しい郵便番号を入力してください（例: 100-0001）')),
      );
      return;
    }

    setState(() {
      _isSearchingPostalCode = true;
    });

    try {
      final result = await PostalCodeService.searchByPostalCode(postalCode);
      
      if (result != null) {
        setState(() {
          _addressController.text = result.fullAddress;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('住所を取得しました')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('該当する住所が見つかりませんでした')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('住所の取得に失敗しました: $e')),
      );
    } finally {
      setState(() {
        _isSearchingPostalCode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '連絡先を編集' : '新しい連絡先'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveContact,
              child: const Text(
                '保存',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 名前（必須）
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名前 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '名前を入力してください';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 電話番号
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '電話番号',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // メールアドレス
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return '正しいメールアドレスを入力してください';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 郵便番号
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: '郵便番号',
                      hintText: '例: 100-0001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (!PostalCodeService.isValidPostalCode(value.trim())) {
                          return '正しい郵便番号を入力してください';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearchingPostalCode ? null : _searchPostalCode,
                  child: _isSearchingPostalCode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('検索'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 住所
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '住所',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              textInputAction: TextInputAction.next,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // 会社名
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: '会社名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // メモ
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),

            // 保存ボタン
            ElevatedButton(
              onPressed: _isLoading ? null : _saveContact,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEditing ? '更新' : '追加',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}