# 準備

- detic_rosのインストール
  - https://github.com/HiroIshida/detic_ros
- jaxon auto stabilizer環境の構築

# 使用例

- simulator 起動
```
rosrun auto_stabilizer_config start-jaxon_red_with_mslhand-sim.sh 
```
- auto stabilizer 起動(必須ではない)
```
roscd auto_stabilizer_config/scripts
ipython3 -i ./jaxon_red_with_mslhand_setup.py
hcf.ast_svc.startAutoBalancer()
hcf.ast_svc.startStabilizer()
```

- detic_ros 起動
```
roslaunch detic_ros sample_detection.launch \
	debug:=true \
	input_image:=/rs_l515/color/image_rect_color \
	input_depth:=/rs_l515/aligned_depth_to_color/image_raw \
	input_camera_info:=/rs_l515/aligned_depth_to_color/camera_info \
	target_frame_id:=rs_l515_depth_optical_frame \
	sync_bounding_box_and_label:=true \
```

- sample-detection.lを実行
  - 初期位置では視界に認識できる物体が映っていないかもしれないので，必要に応じて位置姿勢を調整する

# rviz
- /docker/detic_segmentor/debug_image を見ると，認識しているラベルがわかる
