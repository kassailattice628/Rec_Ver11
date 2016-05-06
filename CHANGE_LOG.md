# Change_log

## 11.5.1
Looming, Grating の時に，最初のフレームを出した後に stim_monitor
（おそらく drawnow で時間食ってる？） 呼ぶと，カメラ使用時に動きが
止まるので，まず stim_monitor 呼んでから， 1st frame を flip．

## 11.5.0
Point Gray, USB-Flea3 を使用して，動画を保存する機能を追加．

## 10.2 -> 11.~.~
function 構造を大きく変更．
