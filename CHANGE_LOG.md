# Change_log
## 11-20200311a
EyeCmaera 保存の際に，mouseごとに別のフォルダに分ける
## 11-100920a
DAQ の eventlistner で カーソル位置を取得するように変更

## 11-190919a
version 番号を日付にする（メインは11）
フリーハンドでマウスを動かして刺激したい
fullscreen で 黒字の figure を出して その上でマウスの動きを検知させてる
（PTB の screen の裏側に figure が出るのでトラックできない）

## 11.5.6 - 190903
ROI のポジションを interactive に変更できるようにした．

##11.5.5 - 190902
Eye Camera ように Grasshopper3 を追加購入．
各トライアルごとに Video file を保存できるようにした．
カメラは NI start の trigger と同期する．

## 11.5.4-m3 - 170510
1. pupil size を記録するため，AI チャネルを増やす @daq_ini.mat．
2. Rotary encoder が 1 列後ろにずれるので，GUI の plot を変更．@dataCaptureNBA.m
3. save する data も修正．@dataCaptureNBA.m

## 11.5.4-m2 - 170420
pattern 毎に position=concentric の挙動を修正．\
stim_monitor を修正．

## 11.5.4-m1 - 170418
stim mode, stim pattern を選択した時の GUI の挙動を修正

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
