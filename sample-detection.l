(require "box-label-synchronizer.l")
(require "package://msl_hand_controller/euslisp/jaxon_red-interface.l")
(require "package://auto_stabilizer/euslisp/auto-stabilizer-interface.l")

(setq *robot* nil)
(setq *target-box* nil)
(setq *box-sync* nil)

(defun sample-detection-init ()
  (jaxon_red-init)
  (setq *robot* *jaxon_red*)
  (setq *box-sync* (instance box-label-synchronizer :init
			   (list (list "/docker/detic_segmentor/output/boxes" jsk_recognition_msgs::BoundingBoxArray)
				 (list "/docker/detic_segmentor/detected_classes" jsk_recognition_msgs::LabelArray))))
  )

(defun detect-pos (label-list)
  (let (target-pos)
    (setq *target-box* nil) ;;リセット
    (send *box-sync* :set-target-label-list label-list)

    (ros::ros-info "detection start")
    (ros::rate 10) ;; 10Hzで探索
    (while (not *target-box*)
      (x::window-main-one) ;;?
      (ros::spin-once)
      (ros::ros-info "waiting for target...")
      (ros::sleep))
    (objects (list *robot* *target-box*))
    (send *irtviewer* :draw-objects)
    (ros::ros-info "targer found at ~A" (send *target-box* :worldpos))
  (setq target-pos (send *target-box* :pos))))

;; main
(sample-detection-init)
(detect-pos (list "stop_sign" "matchbox"))
