# Change_log
## (to do)
Looming の時に，concentric 選んでも，dist と direction 選択できない． \

mode で，Ord 選んだ時に，Fixpos 欄が緑になってしまう場合がある．（value=2 -> 4 に直す）．

## 11.5.4 - 170403
どの刺激でも, position randomize できるようにした．
1. Mode(Position) を
現状の Random, Fix_rep, Ordered から \
Random_mat, Random_conc, Fix_rep, Ordered_mat, Ordered_conc に変更 \
2. Stim.Pattern は
Uni (1P_Conc は Position で選択） \
Size_rand, 2P_Conc, B/W, \
Looming, \
Sin, Rect, Gabor, \
Movebar を新たに入れた． \
Images, Mosaic, FineMap から \


## 11.5.3
Looming 時，刺激と背景の明るさの設定で，どちらが明るくても良いようにチェックを外した．
保存するファイル名は，入力した名前に自動で _ を入れて，その後ろに連番をつける．途中ファイルを消すなどしても，save file フォルダにある一番大きい番号に
1足した数字を自動でつける．

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
