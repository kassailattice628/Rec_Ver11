# Change_log
## 11.5.3
Looming 時，刺激と背景の明るさの設定で，どちらが明るくても良いようにチェックを外した．

## 11.5.2
main_loop で，isloggin(imaq.vid) で while ループまわしてたけど   
取得できた frames をカウントをチェックするようにした．（まだこれで大丈夫微妙）．   
画像の書き出しは， VideoWrite がデフォルト．  
memory にもおいて，元の画像を保存できるようにする．  
PTB の vbl で時間計測できるかとおもったが，DAQ AI の時間と 0 があわせられない．  
やめる．刺激提示の時間は，Photo-sensor の時間をもとにする．  
（一応 tic, toc でも AI の開始時間を計測）．

## 11.5.1
Looming, Grating の時に，最初のフレームを出した後に stim_monitor
（おそらく drawnow で時間食ってる？） 呼ぶと，カメラ使用時に動きが
止まるので，まず stim_monitor 呼んでから， 1st frame を flip．

## 11.5.0
Point Gray, USB-Flea3 を使用して，動画を保存する機能を追加．

## 10.2 -> 11.~.~
function 構造を大きく変更．
