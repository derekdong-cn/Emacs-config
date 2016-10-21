;;; python-mode
(defun prev-def-name ()
  (save-excursion
    (if (re-search-backward "def +\\(.+?\\)(" nil t)
    (match-string 1))))

(defun prev-def-args ()
  (save-excursion
    (if (re-search-backward "def +\\(.+?\\)( *self *,? *\\(.*\\))" nil t)
    (match-string 2))))

(defun prev-class-name ()
  (save-excursion
    (if (re-search-backward "class +\\(.+?\\) *[(:]" nil t)
    (match-string 1))))
