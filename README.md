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
DAQ 以外の機能（PTB, GUI, data save など）がテストできる（はず）．

---
## Visual Stimuli
視覚刺激は，以下のものが使える．
1. "Uni": 丸，四角 の刺激  
2. "Size_rand": サイズ変更  
3. "1P_Conc": 中心点から, dist(deg) まで div_zoom(個）分割した場所に刺激を１点だす．傾きは Direction(deg)．  
4. "2P_Conc": ２点刺激 "1P_Conc" プラス 中心点にも刺激を出す．  
5. "B/W": gray 背景に 1P_Conc で White または Black で刺激出す．  
6. "Looming": Looming speed(deg/s) で 最大 LoonmingSize まで動く．  
7. "Sin", "Rect", "Gabor" グレーティング, direction, temporal frequency, spatial frequency を設定．  
8. "Images", 256 種類の画像ファイルから # of Image （ランダムに）選んで繰り返し提示  
9. "Mosaic", 視野角 dist(deg) で Density(%) 個ランダムな場所に複数ドット（丸 or 四角）を出す．  
1. James Madison
2. James Monroe
3. John Quincy Adams

---


## save data & parameters
初回は File name を押して保存先フォルダ，ファイル名を選択．  
２回目以降は，ファイル名の後に連番で数字が 1 ずつ足されていく．
