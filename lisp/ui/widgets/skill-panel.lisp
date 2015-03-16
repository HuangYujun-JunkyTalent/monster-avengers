;;;; skill-panel.lisp

(in-package #:monster-avengers.simple-web)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (enable-jsx-reader))

(def-widget skill-item (language effect update-callback destructor)
    ()
  #jsx(with-slots (name skills) (aref skill-systems (@ effect id))
	(:li ((class-name "list-group-item"))
	     (:div ((class-name "row"))
		   (:div ((class-name "col-md-4 col-sm-4 col-xs-4"))
                         (lang-text ("zh" (@ name jp))
                                    ("en" (@ name en))))
		   (:div ((class-name "col-md-6 col-sm-6 col-xs-6"))
			 (:select ((class-name "form-control")
                                   (value (@ effect active))
				   (on-change (lambda (e)
                                                (funcall update-callback
                                                         (@ effect id)
                                                         (@ e target value)))))
				  (chain skills 
					 (map (lambda (skill id)
						(:option ((value id))
							 (lang-text ("zh" (@ skill name jp))
                                                                    ("en" (@ skill name en)))))))))
		   (:div ((class-name "col-md-2 col-sm-2 col-xs-2"))
			 (:button ((class-name "btn btn-default")
				   (on-click (lambda () 
					       (funcall destructor (@ effect id)))))
				  (:span ((class-name "glyphicon glyphicon-remove")))))))))

(def-widget skill-panel (language change-callback effects explore-progress achievable-ids)
    ((state (selected 13))
     (add-skill ()
		(funcall change-callback (local-state selected) 0)
		nil)
     (component-will-receive-props ()
                                   (if (= (@ achievable-ids length) 0)
                                       (chain this (set-state (create selected "-1")))
                                       (when (= (chain achievable-ids 
                                                       (index-of (local-state selected)))
                                                -1)
                                         (chain this (set-state (create selected 
                                                                        (aref achievable-ids 0))))))
                                   nil)
     (remove-skill (skill-id)
		   (funcall change-callback skill-id -1)
		   nil))
  #jsx(:div ((class-name "panel panel-default"))
            (:div ((class-name "panel-heading"))
                  (lang-text ("en" "Skills")
                             ("zh" "技能")))
            (:ul ((class-name "list-group"))
		 (chain effects
			(map (lambda (effect) 
			       (:skill-item ((effect effect)
                                             (:language language)
					     (update-callback change-callback)
					     (destructor (@ this remove-skill))))))))
            (:div ((class-name "panel-body"))
                  (:div ((class-name "input-group"))
                        (:select ((class-name "form-control")
                                  (value (local-state selected))
                                  (style :color (if (= (@ achievable-ids length)
                                                       (@ skill-systems length))
                                                    "black"
                                                    "#00BFFF"))
				  (on-change (lambda (e)
                                               (chain this 
                                                      (set-state (create 
                                                                  selected
                                                                  (@ e target value)))))))
                                 (chain achievable-ids
                                        (sort (lambda (x y)
                                                (if (< (@ (aref skill-systems x) name en)
                                                       (@ (aref skill-systems y) name en))
                                                    -1 1)))
                                        (map (lambda (id)
                                               (:option ((value id)
                                                         (style :color (if (= (@ achievable-ids length)
                                                                              (@ skill-systems length))
                                                                           "black"
                                                                           "#00BFFF")))
                                                        (lang-text ("zh" (@ (aref skill-systems id) 
                                                                            name jp))
                                                                   ("en" (@ (aref skill-systems id) 
                                                                            name en))))))))
                        (:div ((class-name "input-group-btn"))
                              (:button ((class-name "btn btn-info")
                                        (disabled (>= (@ effects length) 9))
					(on-click (@ this add-skill)))
                                       (lang-text ("en" "Add")
                                                  ("zh" "添加")))))
                  (when (>= explore-progress 0)
                    (:div ((class-name "progress")
                           (style :margin-top "10px"
                                  :height 32))
                          (:div ((class-name "progress-bar progress-bar-striped active")
                                 (style :width (+ explore-progress "%")
                                        :text-align "right"))
                                (:img ((src "img/ostrich.gif")))))))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (disable-jsx-reader))
