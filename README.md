# 楽々住所録

FlutterとSQLiteを使用した住所録アプリです。

## 機能

### 基本機能
- 連絡先の追加、編集、削除
- 連絡先の詳細表示
- リアルタイム検索機能
- データの永続化（SQLite）

### 画面構成
1. **連絡先一覧画面** - メイン画面
   - 全連絡先の一覧表示
   - 検索バー（名前、電話番号、メール、会社名で検索）
   - スワイプによる編集・削除
   - フローティングアクションボタンで新規追加

2. **連絡先追加・編集画面**
   - 名前（必須）
   - 電話番号
   - メールアドレス（形式チェック付き）
   - 住所
   - 会社名
   - メモ

3. **連絡先詳細画面**
   - 連絡先情報の詳細表示
   - 情報のクリップボードコピー機能
   - 編集・削除ボタン

## 技術仕様

### 使用技術
- **Flutter**: UIフレームワーク
- **SQLite (sqflite)**: ローカルデータベース
- **flutter_slidable**: スワイプ操作
- **Material Design 3**: UIデザイン

### データベース構造
```sql
CREATE TABLE contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone_number TEXT,
  email TEXT,
  address TEXT,
  company TEXT,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

## セットアップ

### 前提条件
- Flutter SDK
- Dart SDK

### インストール手順
1. リポジトリをクローン
2. 依存関係をインストール
   ```bash
   flutter pub get
   ```
3. アプリを実行
   ```bash
   # Webブラウザで実行
   flutter run -d chrome
   
   # Windowsデスクトップで実行
   flutter run -d windows
   
   # 利用可能なデバイスを確認
   flutter devices
   ```

## プロジェクト構造

```
lib/
├── main.dart                    # アプリのエントリーポイント
├── models/
│   └── contact.dart            # Contactモデルクラス
├── database/
│   └── database_helper.dart    # SQLiteデータベースヘルパー
└── screens/
    ├── contact_list_screen.dart    # 連絡先一覧画面
    ├── contact_form_screen.dart    # 連絡先追加・編集画面
    └── contact_detail_screen.dart  # 連絡先詳細画面
```

## 主な機能詳細

### 検索機能
- 名前、電話番号、メールアドレス、会社名での部分一致検索
- リアルタイム検索（入力と同時に結果を更新）

### スワイプ操作
- 右スワイプで編集
- 左スワイプで削除（確認ダイアログ付き）

### データ管理
- SQLiteによるローカルデータ永続化
- 作成日時・更新日時の自動記録
- トランザクション処理によるデータ整合性確保

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
