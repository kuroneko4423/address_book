import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/contact.dart';
import '../database/database_helper.dart';
import 'contact_form_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _deleteContact() async {
    try {
      await _databaseHelper.deleteContact(_contact.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_contact.name}を削除しました')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('削除に失敗しました: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: Text('${_contact.name}を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteContact();
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${label}をクリップボードにコピーしました')),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String? value,
    VoidCallback? onTap,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () => _copyToClipboard(value, label),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactFormScreen(contact: _contact),
                ),
              ).then((result) {
                if (result != null) {
                  Navigator.of(context).pop();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // プロフィール画像とヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _contact.name.isNotEmpty ? _contact.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _contact.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_contact.company != null && _contact.company!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _contact.company!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 連絡先情報
            _buildInfoCard(
              icon: Icons.phone,
              label: '電話番号',
              value: _contact.phoneNumber,
            ),
            _buildInfoCard(
              icon: Icons.email,
              label: 'メールアドレス',
              value: _contact.email,
            ),
            _buildInfoCard(
              icon: Icons.location_on,
              label: '郵便番号',
              value: _contact.postalCode,
            ),
            _buildInfoCard(
              icon: Icons.location_on,
              label: '住所',
              value: _contact.address,
            ),
            _buildInfoCard(
              icon: Icons.business,
              label: '会社名',
              value: _contact.company,
            ),
            _buildInfoCard(
              icon: Icons.note,
              label: 'メモ',
              value: _contact.notes,
            ),

            const SizedBox(height: 24),

            // 作成・更新日時
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          '詳細情報',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '作成日時:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          '${_contact.createdAt.year}/${_contact.createdAt.month.toString().padLeft(2, '0')}/${_contact.createdAt.day.toString().padLeft(2, '0')} ${_contact.createdAt.hour.toString().padLeft(2, '0')}:${_contact.createdAt.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '更新日時:',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          '${_contact.updatedAt.year}/${_contact.updatedAt.month.toString().padLeft(2, '0')}/${_contact.updatedAt.day.toString().padLeft(2, '0')} ${_contact.updatedAt.hour.toString().padLeft(2, '0')}:${_contact.updatedAt.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}