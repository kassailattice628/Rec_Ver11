# NoneButAir_Rec_Ver11.5.0

MATLAB, Psychtoolbox3 を使っての視覚刺激制御と  
DAQ toolbox (session-based), NIDAQmx ドライバ で NI DAQを制御．
眼球運動記録用に IMAQ toolbox を使用．

3チャンネル AI, ロータリィエンコーダ から記録．  
毎回ループのはじめに P0.0 から TTL 出力．  
１番はじめの Loop Start タイミングで P0.1 から TTL 出力．  
視覚刺激のタイミングにあわせて P0.2 の TTL ON/OFF．  

外部 TTL pulse 出力として AO0 を使用．

眼球記録用に Point Grey Flea3(USB3)を使用．

---
## Requirement
Windows7 64bit, 8 でも動くが Psychtoolbox3 の同期，タイミング制御が不安．  
Windows10 は試したことない．  
MATLAB 64bit R2015b をメインで使用．その前後でも大丈夫だと思う．  
Data acquisition toolbox が必要．  
\(イメージングの解析には Image Processing toolbox も\)．  
NIDAQmx は，NI から直接ダウンロードした．  
R2016 以降は, MATLAB のメニュー，アドオン　＞　ハードウェアサポートパッケージの入手 から．   
NI の DAQ としては，USB 接続の BNC コネクタ付きのものを使用している \(USB6341BNC\)．  
USB6001 等では TTL3 に設定した AO パルスが同時に使えない．

視覚刺激用に Psychtoolbox3 を使用.   
[Psychtoolbox3]("http://psychtoolbox.org/download/") から指示に従って最新版を入れる．

Point Grey モノクロカメラを使用．  
[Flea3: FL3-U3-13Y3M-C]("https://www.ptgrey.com/flea3-13-mp-mono-usb3-vision-vita-1300-camera")

### 注意  
DAQ は 使用する PC に 1 台だけつなげばその認識してくれる．  
複数使用する場合は，daq_ini.m の中で機器名を指定する必要あり．

---
## Usage
OpenNBA.m を実行．  
開いたウィンドウから "Start NBA" ボタンを押すと起動．

NI 機器につながっていない，DAQ toolbox が使えない環境では，"Testmode" を ON にして "START NBA" を起動すると
DAQ 以外の機能 \(PTB, GUI, data save など\) がテストできる\(はず\)．．．  
dual-display 環境では Loop ボタンで視覚刺激の スタート\/ストップを制御．  

Single-display 環境では ５回 刺激出したら Screen('Close') を読んで 画面をもどる．

---
## Visual Stimuli
視覚刺激は，以下のものが使える．
* "Uni": 丸，四角 の刺激
* "Size_rand": サイズ変更
* "1P\_Conc": 中心点から, dist \(deg\) まで div\_zoom \(個\)分割した場所に刺激を１点だす．傾きは Direction \(deg\)．
* "2P\_Conc": ２点刺激 "1P\_Conc" プラス 中心点にも刺激を出す．
* "B/W": gray 背景に 1P\_Conc で White または Black で刺激出す．
* "Looming": Looming speed \(deg/s\) で 最大 LoonmingSize まで動く．
* "Sin", "Rect", "Gabor" グレーティング, direction, temporal frequency, spatial frequency を設定．
* "Images", 256 種類の画像ファイルから # of Image \(ランダムに\)選んで繰り返し提示
* "Mosaic", 視野角 dist \(deg\) で Density \(%\) 個ランダムな場所に複数ドット \(丸 or 四角\) を出す．
* "FineMapp", Fixed position を中心に，sobj.dist\^2 の小領域を sobj.div_zoom∧２ に分割して刺激をだす．

"1P\_Conc" と "FineMap" のときは 刺激モニタを 200^2 分割した 場所に対応する場所を検索して Fixed position として反映できる．

---
## Save data & Parameters
初回は File name を押して保存先フォルダ，ファイル名を選択．  
２回目以降，File name をつけ直さない場合は，ファイル名の後に連番で数字が 1 ずつ足されていく．

動画データはトライアルごとに 連番が追加される．

---
## Information about parameters
### recobj

### sobj

### DataSave
1. Time in sec.
2. AI0
3. AI1
4. AI2 = Photo Censer
5. AI3 = Trigger Monitor
6. Rotary Encoder

### ParamsSave
1. stim1
  * On_time
  * Off_time
  * lumi
  * color
  * center_position, centerX_pix, centerY_pix
  * size
  * dist_deg
  * angle_deg
  * LoomingSpd_deg_s
  * LoomingMaxSize_deg
  * gratingSF_cyc_deg
  * gratingSpd_Hz
  * gratingAngle_deg
  * RandPosition_seed
  * RandSize_seed
  * position_deg_mat
  * size_deg_mat
  * center_position_FineMap
2. stim2
  * On_time
  * Off_time
  * lumi
  * color
  * center_position, centerX_pix, centerY_pix
  * size
  * dist_deg
  * angle_deg
3. cycleNum
4. RecStartTime

### MP4 ビデオ
カメラを ON にして save すると MP4 形式でトライアルごとの動画を保存．
