# NoneButAir_Rec_Ver11.03

MATLAB, DAQ toolbox (session-based), NIDAQ をつかって
3チャンネル AI, ロータリィエンコーダ から記録．

各タイミングで TTL 出力
AO0 から pulse 出力

Psychtoolbox3 を使って，視覚刺激を出す

## Use
OpenNBA.m を実行．
開いた window から Start NBA．
NI 機器につながっていない，DAQ toolbox が使えない環境では
Testmode を ON にして START NBA すると
記録系以外の機能はテストできる．

## Visual Stimuli
視覚刺激としては
丸，四角 の刺激，サイズ変更，２点刺激，ルーミング，グレーティング，画像
が使える．

モザイク刺激を使えるようにしたい．
