
// ---------------------------------------------------------------------------
// キャッシュの設定
//
// ディスクキャッシュを使用しない
user_pref("browser.cache.disk.enable", false);
user_pref("browser.cache.disk_cache_ssl", false);
// メモリキャッシュを使用する
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.max_entry_size", 10248);
// 戻る・進む機能の最大保存履歴数
user_pref("browser.sessionhistory.max_total_viewers", 3);

// ---------------------------------------------------------------------------
// HTTP接続設定
//
// 接続数の上限
user_pref("network.http.max-connections", 64);
// 1サーバ毎の接続数の上限
// user_pref("network.http.max-connections-per-server", 8);
// 1プロキシ毎の持続的接続数の上限
user_pref("network.http.max-persistent-connections-per-proxy", 4);
// 1サーバ毎の持続的接続数の上限
user_pref("network.http.max-persistent-connections-per-server", 4); 
// IPv6用のDNSリクエストを無効
user_pref("network.dns.disableIPv6", true);
// リンク先の先読みを無効
user_pref("network.prefetch-next", false);

// ---------------------------------------------------------------------------
// パイプライン設定
//
// 非プロキシ接続の時、パイプライン処理をさせる
user_pref("network.http.pipelining", true);
// 通信のうちの最初の要求でパイプライン処理を使うか
user_pref("network.http.pipelining.firstrequest", false);
// 一度のパイプライン処理で送信する最大要求数
user_pref("network.http.pipelining.maxrequests", 8);
// SSL接続の時、パイプライン処理をさせる
user_pref("network.http.pipelining.ssl", true);
// プロキシ接続の時、パイプライン処理をさせる
user_pref("network.http.proxy.pipelining", true);

// ---------------------------------------------------------------------------
// レンダリング設定 (高速化)
//
// ページをレンダリングする前の待ち時間
user_pref("nglayout.initialpaint.delay", 100);
// ページのレンダリング中の基準時間の有効化(?)
user_pref("content.notify.ontimer", true);
// content.notify.backoffcountで決めた初期量の時間の間隔(?)
user_pref("content.notify.interval", 100000);
// ページの大まかなレイアウトの計算がすんだ時に、基準時間でのレンダリングが始まるまでのページの再処理時間(?)
user_pref("content.notify.backoffcount", 5);

// ---------------------------------------------------------------------------
// レンダリング設定 (描画)
//
// user_pref("layers.acceleration.disabled", false);
// user_pref("layers.acceleration.force-enabled", true);
// user_pref("gfx.direct2d.disabled", false);
// user_pref("gfx.direct2d.force-enabled", true);
// user_pref("gfx.font_rendering.cleartype.always_use_for_content", true);
// user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
// user_pref("gfx.font_rendering.cleartype_params.enhanced_contrast", 200);
// user_pref("gfx.font_rendering.cleartype_params.pixel_structure", 1);
// user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
// user_pref("gfx.font_rendering.directwrite.enabled", true);
// user_pref("gfx.use_text_smoothing_setting", true);

// (default settings)
// user_pref("layers.acceleration.disabled", false);
// user_pref("layers.acceleration.force-enabled", false);
// user_pref("gfx.direct2d.disabled", false);
// user_pref("gfx.direct2d.force-enabled", false);
// user_pref("gfx.font_rendering.cleartype.always_use_for_content", false);
// user_pref("gfx.font_rendering.cleartype_params.cleartype_level", -1);
// user_pref("gfx.font_rendering.cleartype_params.enhanced_contrast", -1);
// user_pref("gfx.font_rendering.cleartype_params.pixel_structure", -1);
// user_pref("gfx.font_rendering.cleartype_params.rendering_mode", -1);
// user_pref("gfx.font_rendering.directwrite.enabled", false);
// user_pref("gfx.use_text_smoothing_setting", false);

// ---------------------------------------------------------------------------
// UI関連
//
// 言語設定
user_pref("general.useragent.locale", "ja-JP");
// 全画面表示のアニメーションを無効
user_pref("browser.fullscreen.animateUp", 0);
// タブ開閉のアニメーションを無効
user_pref("browser.tabs.animate", false);
// タブの閉じるボタンの表示形式 
user_pref("browser.tabs.closeButtons", 2);
// タブグループのアニメーションを無効
user_pref("browser.panorama.animate_zoom", false);
// ツールチップを無効にする
// user_pref("browser.chrome.toolbar_tips", false);
// Ctrl+Tabでのタブプレビューを有効化
// user_pref("browser.ctrlTab.previews", true);
// 右クリックを禁止させない
user_pref("dom.event.contextmenu.enabled", false);
user_pref("nglayout.events.dispatchLeftClickOnly", true);
// フレームの強制リサイズを可能にする
user_pref("layout.frames.force_resizability", true);
// about:pluginsでプラグインの完全な位置を示します
user_pref("plugin.expose_full_path", true);
// アドオンインストール時の待機時間
user_pref("security.dialog_enable_delay", 0);
// サブメニュー表示までの待機時間
user_pref("ui.submenuDelay", 0);
// ソース表示時に右端を折り返す
user_pref("view_source.wrap_long_lines", true);
// ドメインハイライト機能を無効にする
user_pref("browser.urlbar.formatting.enabled", false);
// ロケーションバーに「http://」を表示
user_pref("browser.urlbar.trimURLs", false);
// 検索結果を新しいタブで表示
user_pref("browser.search.openintab", true);

// ---------------------------------------------------------------------------
// その他
//
// サイトの自動更新を無効にする
user_pref("accessibility.blockautorefresh", false);
// テキストの点滅を無効にする
user_pref("browser.blink_allowed", false);
// 文字のスクロール表示を無効にする
user_pref("browser.display.enable_marquee", false);
// gifのアニメーションを1回だけにする
// user_pref("image.animation_mode", "once");
// ダウンロード後のウイルススキャンを無効にする
user_pref("browser.download.manager.scanWhenDone", false);
// ダウンロード完了時のポップアップを無効にする
user_pref("browser.download.manager.showAlertOnComplete", false);
// ダウンロード完了時のダウンロードマネージャウィンドウ表示を無効にする
user_pref("browser.download.manager.showWhenStarting", false);
// 最小化時のメモリ使用量を抑える
user_pref("config.trim_on_minimize", true);
// 位置検出情報を無効にする
user_pref("geo.enabled", false);

