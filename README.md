# NoneButAir_Rec_Ver11.03

MATLAB, Psychtoolbox3 を使っての視覚刺激制御と  
DAQ toolbox (session-based), NIDAQmx ドライバ で NI DAQを制御．

3チャンネル AI, ロータリィエンコーダ から記録．  
毎回ループのはじめに P0.0 から TTL 出力．  
１番はじめの Loop Start タイミングで P0.1 から TTL 出力．  
視覚刺激のタイミングにあわせて P0.2 の TTL ON/OFF．

外部 TTL pulse 出力として AO0 を使用．

---
## Usage
OpenNBA.m を実行．  
開いたウィンドウから "Start NBA" ボタンを押すと起動．

NI 機器につながっていない，DAQ toolbox が使えない環境では，"Testmode" を ON にして "START NBA" を起動すると
DAQ 以外の機能 \(PTB, GUI, data save など\) がテストできる\(はず\)．．

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
## save data & parameters
初回は File name を押して保存先フォルダ，ファイル名を選択．  
２回目以降は，ファイル名の後に連番で数字が 1 ずつ足されていく．
