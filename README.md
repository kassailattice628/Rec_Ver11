# NoneButAir_Rec_Ver11.5.3

MATLAB, Psychtoolbox3 を使っての視覚刺激制御．  
DAQ toolbox (session-based), NIDAQmx ドライバ, NI DAQにによるアナログ入出力．  
IMAQ toolbox, FlyCapture2 ドライバ, Point Gray USB Flea3 による動画記録．  

---
## Requirement
Windows7 64bit.  
Windows8 でも動くが Psychtoolbox3 での２画面同期，タイミング制御が不安．  
Windows10 は試したことない．  
MATLAB 64bit R2015a, b, 2016a で動作確認済み．  
視覚刺激用に Psychtoolbox3 を使用．  
[Psychtoolbox3]("http://psychtoolbox.org/download/") から指示に従って最新版を入れる．

Data acquisition toolbox (64bit)．
NIDAQ サポートパッケージ (MATLAB アドオンから入手)．  
Image acquisition toolbox．  
Point Gray サポートパッケージ (MATLAB アドオンから入手)．  

OSX 10.9 -10.12 では 記録系は動かせないが，刺激パタンの確認等は可能．  

### ドライバインストール注意
おそらく R2016a 以降は MATLAB のアドオン追加機能でドライバを入れたほうが良い．  
（メニュー，アドオン　＞　ハードウェアサポートパッケージの入手）．   
National Instruments や Point Gray から最新版の  NIDAQ-mx や FlyCapture2SDK  
を入れても機器が認識されない場合がある．  
その場合は，システムから NIDAQ-mx,  FlyCapture2SDK をアンインストールした後  
アドオンからサポートパッケージを入手，でインストールする必要あり．  
(アドオンでインストールされるものは，最新版のドライバではないことにも注意）．  

LabVIEW や C でFlyCapture2SDK を使用している場合はどうするのか不明？  

## 使用機器
NI の DAQ としては，USB 接続の BNC コネクタ付きのものを使用している (USB6341BNC)．  
USB 接続が遅い場合は，PCIe 接続のものを使用したほうが無難．  
（USB6001 等では TTL3 に設定した AO パルスが同時に使えないなど機能制限あり）．  

Point Grey モノクロカメラを使用．  
[Flea3: FL3-U3-13Y3M-C]("https://www.ptgrey.com/flea3-13-mp-mono-usb3-vision-vita-1300-camera")

### 注意  
DAQ は 使用する PC に 1 台だけつなげばその認識してくれる．  
複数使用する場合は，daq_ini.m の中で機器名を指定する必要あり．  
カメラを複数使用する場合も imaq_ini.m 等を変更．  

### 入出力
3チャンネル AI(0:2) アナログ入力．
AI3 は記録開始のトリガーモニターとして使用．

1チャンネル AO0 アナログ出力（パルス出力用)．  
ロータリィエンコーダ から記録．

毎回ループのはじめに P0.0 から TTL 出力．  
１番はじめの Loop Start タイミングで P0.1 から TTL 出力（FV1000 イメージング開始信号として使用中）．  
視覚刺激のタイミングにあわせて P0.2 の TTL ON/OFF．  

外部 TTL pulse 出力として AO0 を使用．

眼球記録用に Point Grey Flea3(USB3)を使用．
Preview しながら Save は キツイので，Preview はカメラの位置確認程度．

---
## Usage
OpenNBA.m を実行．  
開いたウィンドウから "Start NBA" ボタンを押すと起動．

NI 機器につながっていない，DAQ toolbox が使えない環境では，"Testmode" を ON にして "START NBA" を起動すると
DAQ 以外の機能 \(PTB, GUI, data save など\) がテストできる\(はず\)．．．  
dual-display 環境では Loop ボタンで視覚刺激の スタート\/ストップを制御．  

IMAQ toolbox で動画記録する場合は, "UseCam" を ON．  
カメラが使用できない場合は，ボタンをしても エラー．

Single-display 環境では ５回 刺激出したら Screen('Close') を読んで 画面をもどる．

---
## Visual Stimuli
視覚刺激のパタンは，以下のものが使える．
* "Uni": 丸，四角 の刺激
* "Size_rand": サイズ変更
* "1P\_Conc": 中心点から, dist \(deg\) まで div\_zoom \(個\)分割した場所に刺激を１点だす．傾きは Direction \(deg\)．
* "2P\_Conc": ２点刺激 "1P\_Conc" プラス 中心点にも刺激を出す．
* "B/W": gray 背景に 1P\_Conc で White または Black で刺激出す．
* "Looming": Looming speed \(deg/s\) で 最大 LoonmingSize まで動く．
* "Sin", "Rect", "Gabor" グレーティング, direction, temporal frequency, spatial frequency を設定．
* "Images", 256 種類の画像ファイルから # of Image \(ランダムに\)選んで繰り返し提示
* "Mosaic", 視野角 dist \(deg\) で Density \(%\) 個ランダムな場所に複数ドット \(丸 or 四角\) を出す．
* "FineMapp", Fixed position を中心に，(sobj.dist)<sup>2</sup> の小領域を sobj.div_zoom<sup>2</sup> に分割して刺激をだす．

"1P\_Conc" と "FineMap" のときは 刺激モニタを 200<sup>2</sup> 分割した 場所に対応する場所を検索して Fixed position として反映できる．

---
## Save data & Parameters
初回は File name を押して保存先フォルダ，ファイル名を選択．  
２回目以降，File name をつけ直さない場合は，ファイル名の後に連番で数字が 1 ずつ足されていく．

動画データは "Movie" フォルダに トライアルごとに連番が追加．   

---
## Parameter structures
### recobj
記録全般に関わるパラメタをまとめた．

### sobj
視覚刺激に関するパラメタをまとめた．

### imaq
カメラ動画記録に関するパラメタをまとめた．

### figUIobj
Figure components（ボタンなど）をまとめたもの．

### s, sOut, dio
DAQ toolbox で生成した AI, AO, DIO セッションをまとめた構造体．

### lh
AI 記録で実行されるイベントの，event handle.

---
## Logged Data
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

---
### .m ファイル説明
1. OpenNBA.m
  Start NBA_rec and select Recording Mode.
2. main_loop.m



---
### To Do

