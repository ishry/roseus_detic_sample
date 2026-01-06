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
### auto stabilizer 起動(必須ではない)
```
roscd auto_stabilizer_config/scripts
ipython3 -i ./jaxon_red_with_mslhand_setup.py
hcf.ast_svc.startAutoBalancer()
hcf.ast_svc.startStabilizer()
```

### detic_ros 起動
```
roslaunch detic_ros sample_detection.launch \
	debug:=true \
	input_image:=/rs_l515/color/image_rect_color \
	input_depth:=/rs_l515/aligned_depth_to_color/image_raw \
	input_camera_info:=/rs_l515/aligned_depth_to_color/camera_info \
	target_frame_id:=rs_l515_depth_optical_frame \
	sync_bounding_box_and_label:=true \
```
- target_frame_idについて
  - RGB画像，depth画像はそれぞれ特定の座標系から撮影されており，一般に両者の座標系は異なる
    - 確認方法：`rostopic echo /rs_l515/color/image_rect_color/header -n 1`  など
  - deticを使用する時は，両者の座標系を揃えないといけない．
  	- 揃えていない場合，/docker/detic_segmentor/output/boxes がpublishされない(気がする)
  - aligned_depth_to_color系のトピックは，realsense側がdepth画像をRGB画像の座標系に変換してpublishしてくれているトピックなので，これを利用すると良い．input_camera_infoも同様．
  - 統一した方の座標系をtarget_frame_idに指定する．
  - 以上を踏まえると，input_depthやinput_camera_infoにaligned_depth_to_color系トピックを使い，target_frame_idをcolor_optical_frameとするのが基本．
  	- ただし，jaxonのchoreonoid環境では，depth_optical_frameで両方のトピックをpublishする設定になっているので，それに従っている．	 
- sync_bounding_box_and_labelについて
  - /docker/detic_segmentor/output/boxesと/docker/detic_segmentor/detected_classesはnsec以下で周期がずれているので，exact_time_message_filterを用いるとcallbackがほとんど呼ばれなくなってしまう
    - exact_time_message_filterはトピックのヘッダーのタイムスタンプが完全に一致したときにcallbackを呼ぶクラス
  - sync_bounding_box_and_labelオプションにより，多少周期が遅くなるがトピックが同期しやすくなる


### sample-detection.lを実行
- 初期位置では視界に認識できる物体が映っていないかもしれないので，必要に応じて位置姿勢を調整する．
- box-label-synchronizer.lの中に，座標変換をしている箇所がある．target_frame_idとして使用した座標系に書き換えておくこと．

## rviz
- /docker/detic_segmentor/debug_image を見ると，認識しているラベルが分かる
