(require 'init-evil) ; init-evil dependent on init-clipboard
;;(org-latex-pdf-process '("xelatex -interaction nonstopmode %f" "xelatex -interaction nonstopmode %f"))
;; load solarized-theme
;; https://github.com/sellout/emacs-color-theme-solarized
(setq frame-background-mode 'dark)
(let ((basedir "~/.emacs.d/elpa-28.1/themes/"))
  (dolist (f (directory-files basedir))
    (if (and (not (or (equal f ".") (equal f "..")))
             (file-directory-p (concat basedir f)))
        (add-to-list 'custom-theme-load-path (concat basedir f)))))
(load-theme 'solarized t)
(set-face-attribute 'default nil :height 140)
(set-default 'truncate-lines t)
(provide 'init-local)



