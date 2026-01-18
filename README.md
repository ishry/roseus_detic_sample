# roseus_detic_sample

## 準備

- detic_rosのインストール
	- https://github.com/HiroIshida/detic_ros
- jaxon auto stabilizer環境の構築

## 使用例

### simulator 起動
```
rosrun auto_stabilizer_config start-jaxon_red_with_mslhand-sim.sh 
```

### detic_ros 起動
```
roslaunch detic_ros sample_detection.launch \
	debug:=true \
	input_image:=/rs_l515/color/image_rect_color \
	input_depth:=/rs_l515/aligned_depth_to_color/image_raw \
	input_camera_info:=/rs_l515/aligned_depth_to_color/camera_info \
	target_frame_id:=BODY \
	sync_bounding_box_and_label:=true \
```
- input_image / input_ depth / input_camera_infoについて
  - RGB画像，depth画像はそれぞれ特定の座標系から撮影されており，一般に両者の座標系は異なる
    - 確認方法：`rostopic echo /rs_l515/color/image_rect_color/header -n 1`  など
  - deticを使用する時は，両者の座標系を揃えないといけない．
  	- 揃えていない場合，/docker/detic_segmentor/output/boxes がpublishされない
  - aligned_depth_to_color系のトピックは，realsense側がdepth画像をRGB画像の座標系に変換してpublishしてくれているトピックなので，これを利用すると良い．input_camera_infoも同様．
  	- ただし，jaxonのchoreonoid環境では，depth_optical_frameで両方のトピックをpublishする設定になっている場合がある．
- target_frame_id について
  - /docker/detic_segmentor/output/boxes をどのtf座標系で出力するかを指定する箇所．
  - roseusで使いやすいように，ロボットのルート座標系にしておくといいかも
  - 一応，box-label-synchronizer.l 側でも座標変換することはできる．
- sync_bounding_box_and_labelについて
  - /docker/detic_segmentor/output/boxesと/docker/detic_segmentor/detected_classesはnsec以下で周期がずれているので，exact_time_message_filterを用いるとcallbackがほとんど呼ばれなくなってしまう
    - exact_time_message_filterはトピックのヘッダーのタイムスタンプが完全に一致したときにcallbackを呼ぶクラス
  - sync_bounding_box_and_labelオプションにより，多少周期が遅くなるがトピックが同期しやすくなる
- メモ
  - 問題：choreonoid環境でsample_detection.launchを実行した時に，Transform error: Failed to lookup trasformation ... となる
	- 原因：hrpsysの起動タイミングの影響で，hrpsysが実時間モードで起動してしまい，/tf トピックが実時間で出ていた．その他のトピックは/clock を参照したsim時間なので，整合性が取れなくなっていた．
	- 対処：hrpsysを立ち上げるタイミングで，use_sim_time(rosparam)がtrueかつ，/clockが出ていればsim時間でtfが出るはずなので，頑張って立ち上げ直す

### sample-detection.lを実行
- 初期位置では視界に認識できる物体が映っていないかもしれないので，必要に応じて位置姿勢を調整する．

## rviz
- /docker/detic_segmentor/debug_image を見ると，認識しているラベルが分かる
