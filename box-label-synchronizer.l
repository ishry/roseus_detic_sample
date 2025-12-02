(ros::load-ros-manifest "jsk_recognition_msgs")

;;検知したboxとラベルを対応させるクラス
(defclass box-label-synchronizer
  :super exact-time-message-filter
  :slots (target-label-list target-box)
  )

(defmethod box-label-synchronizer
  (:callback (box-msg label-msg)
    (print (list box-msg label-msg))
    (print (send-all (list box-msg label-msg) :header :stamp))
    (box-cb box-msg label-msg target-label-list)
    ))

;;検知したいラベルをリストで渡す
(defmethod box-label-synchronizer
    (:set-target-label-list (label-list)
     (setq target-label-list label-list)))

;;コールバック関数
(defun box-cb (box-msg label-msg label-list)
  (ros::ros-info "received ~A boxes, ~A labels" (length (send box-msg :boxes)) (length (send label-msg :labels)))
  (dolist (msg-conbined (map cons #'(lambda (x y) (list  x y)) (send box-msg :boxes) (send label-msg :labels)))
    (let (box label target-coords-camera target-coords target-dimensions)
      (setq box (car msg-conbined) label (cadr msg-conbined))
      (print (send label :name))
      (when (contains label-list (send label :name))
        ;;カメラ座標系
	(setq target-coords-camera (send (ros::tf-pose->coords (send box :pose)) :copy-worldcoords))
	;;jaxon(腰)から見た座標系に変換
	(setq target-coords (transform-coords (send *robot* :rs_l515_depth_optical_frame :worldcoords) target-coords-camera))
	(setq target-dimensions (send box :dimensions))
	(format t "coords ~A, dimension~A~%" (send target-coords :worldcoords) (* (send target-dimensions :x) (send target-dimensions :y) (send target-dimensions :z)))
	;;検出位置に制限をつける場合
	(when (and (< (elt (send target-coords :worldpos) 2) 10000)
		   (> (elt (send target-coords :worldpos) 2) -10000))
	  (setq *target-box* (make-cube 100 100 100 :pos #f(0 0 0)))
	  (send *target-box* :move-to target-coords :world)
	  (setq *target-box-dimentions* target-dimensions)
	  (print "update target position"))))))
	
;;listにwordが含まれていればt,含まれていなければnilを返す関数
(defun contains (list word)
  (let ((tmp nil))
    (while list
      (if (string= word (car list)) 
          (progn (setq tmp t) (return))
	(setq list (cdr list))))
    tmp))
