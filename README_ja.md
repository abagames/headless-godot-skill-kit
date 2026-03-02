# Headless Godot Skill Kit

[English](README.md) | 日本語

AI コーディングエージェント + Godot（headless）で、Godot エディタを開くことなくゲーム開発を行うための Agent Skill キット。シーン編集・テスト・エクスポートをエージェントに指示でき、ブラウザで動作確認しながら開発を進められる。

## 前提条件

- Godot 4.2+（`godot --version` で確認）
- Web エクスポートを行う場合は [Export Templates](https://docs.godotengine.org/ja/4.x/tutorials/export/exporting_projects.html) の導入が必要

## 導入

対象プロジェクトのルートに `.agents/` をコピーする。

```bash
cp -r /path/to/headless-godot-skill-kit/.agents /path/to/your-project/
```

あとはエージェントに指示を出せば、シーン編集・テスト・エクスポートまで実行できる。エクスポートされた Web ビルド（`build/web/index.html`）をブラウザで確認する。

**注意:** このスキルはルールとリファレンスを提供するが、ワークフローの自動実行は定義していない。毎回の変更後にパイプライン（パッチ → テスト → Web エクスポート）を自動で回したい場合は、プロジェクトの `AGENTS.md` にワークフロー指示を追加する。例:

```markdown
## ワークフロー

変更後、以下のパイプラインを毎回実行する:
1. `godot_apply_patch.gd` でパッチ適用
2. 起動スモーク（headless 5秒）
3. ロジックテスト（`--script res://tools/tests/run_tests.gd`）
4. Web エクスポート（`--export-release "Web" build/web/index.html`）
```

エージェントが生成するシーン構築スクリプトやテストケース、パッチ定義を手動で微調整し、`tools/rebuild_web.sh` で再実行することもできる。

## トラブルシューティング

### XDG 環境変数

サンドボックス等で `~/.local` / `~/.cache` が使えない場合は、`XDG_DATA_HOME` 等をプロジェクト内に向ける。詳細はスキルの `export_and_import.md` を参照。

エクスポート以外も含む headless 実行の基本形:

```bash
mkdir -p <PROJECT_DIR>/.tmp-godot-data <PROJECT_DIR>/.tmp-godot-config <PROJECT_DIR>/.tmp-godot-cache
XDG_DATA_HOME=<PROJECT_DIR>/.tmp-godot-data \
XDG_CONFIG_HOME=<PROJECT_DIR>/.tmp-godot-config \
XDG_CACHE_HOME=<PROJECT_DIR>/.tmp-godot-cache \
godot --headless --path <PROJECT_DIR> ...
```

### Export Templates の参照先

`XDG_DATA_HOME` を変更すると Export Templates の参照先も変わる。`export_presets.cfg` の `custom_template/debug` / `custom_template/release` に絶対パスを設定して固定できる。

### TCP listen 警告

headless 実行時に出る場合があるが、エクスポートが成功し `index.html` / `index.pck` / `index.wasm` が生成されていれば問題ない。

### RID/Object leak 警告（`--script`）

`--script` でシーン生成・保存を行うと、終了時に RID/Object leak 警告が出る場合がある。
終了コードが `0` で、想定成果物が生成されているなら既知警告として扱ってよい。
終了コード非0、または成果物不足の場合は失敗として扱う。

### Patch applier script が見つからない

`res://tools/godot_apply_patch.gd` が見つからない場合は、プロジェクト内へ復元して再実行する。

```bash
mkdir -p /path/to/your-project/tools
cp /path/to/your-project/.agents/skills/headless-godot/tools/godot_apply_patch.gd /path/to/your-project/tools/godot_apply_patch.gd
```

Patch コマンドは `res://tools/godot_apply_patch.gd` を前提とし、`<PATCH_JSON_PATH>` には絶対パスまたは `res://` を使う。

---

## 技術詳細

以下はスキルの内部動作に興味がある読者向けの情報である。通常の利用では意識する必要はない。

### エージェントが行うワークフロー

エージェントは通常、以下のサイクルで作業を進める。

```
patch.json を作成
  ↓
--dry-run で事前検証（NodePath 解決・型チェック）
  ↓
godot_apply_patch.gd で .tscn に適用
  ↓
起動スモーク（headless 5秒、参照切れやスクリプトエラーの検出）
  ↓
ロジックテスト（--script res://tools/tests/run_tests.gd）
  ↓
Web エクスポート
```

- `.tscn` の直接テキスト編集は行わず、JSON パッチ → Godot API 経由で安全に更新する
- すべてのコマンド出力は `logs/` に保存され、障害追跡に使える

### リポジトリ構成

```
.agents/skills/headless-godot/
  ├── SKILL.md                        # スキル定義（エージェントのエントリポイント）
  ├── skills/
  │   ├── headless_cli.md             # CLI 規約（--path, --headless, ログ保存）
  │   ├── scene_editing_via_godot.md  # シーン編集ルール（パッチフロー、安全策）
  │   ├── testing_headless.md         # テスト戦略（スモーク、ロジックテスト）
  │   └── export_and_import.md        # エクスポート規約
  └── tools/
      ├── godot_apply_patch.gd        # パッチ適用スクリプト本体
      └── templates/
          └── run_tests.gd            # テストスクリプトのテンプレート
```

## 参考リンク

- [Godot CLI チュートリアル](https://docs.godotengine.org/ja/4.x/tutorials/editor/command_line_tutorial.html)
- [Godot エクスポートガイド](https://docs.godotengine.org/ja/4.x/tutorials/export/exporting_projects.html)
