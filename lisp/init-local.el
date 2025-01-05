;;(org-latex-pdf-process '("xelatex -interaction nonstopmode %f" "xelatex -interaction nonstopmode %f"))
;; load solarized-theme
;; https://github.com/sellout/emacs-color-theme-solarized
(setq frame-background-mode 'dark)
(let ((basedir "~/.emacs.d/elpa-29.4/themes/"))
  (dolist (f (directory-files basedir))
    (if (and (not (or (equal f ".") (equal f "..")))
             (file-directory-p (concat basedir f)))
        (add-to-list 'custom-theme-load-path (concat basedir f)))))
(load-theme 'sanityinc-solarized-dark t)
(set-face-attribute 'default nil :height 140)
(set-default 'truncate-lines t)
(require-package 'sis)
(require-package 'plantuml-mode)
(require-package 'use-package)
(require-package 'ox-hugo)
(require-package 'org-download)

;; Drag-and-drop to `dired`
(add-hook 'dired-mode-hook 'org-download-enable)
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(setq yas-snippet-dirs
      '("~/Dropbox/org/snippets"
        ))

(use-package sis
  ;; :hook
  ;; enable the /follow context/ and /inline region/ mode for specific buffers
  ;; (((text-mode prog-mode) . sis-follow-context-mode)
  ;;  ((text-mode prog-mode) . sis-inline-mode))

  :config

  ;; Windows
  ;;(sis-ism-lazyman-config "1033" "2052" 'im-select)
  (when *is-a-mac*
    (sis-ism-lazyman-config
     "com.apple.keylayout.US"
     "im.rime.inputmethod.Squirrel.Hans" 'macism ))
  ;;(when *sys/wsl*
  ;;  (setq sis-english-source "1033")
  ;;  (setq sis-other-source "2052")
  ;;  (setq sis-do-get (lambda ()
  ;;                     (sis--ensure-dir
  ;;                      (string-trim (shell-command-to-string "im-select.exe")))))
  ;;  (setq sis-do-set (lambda(source)
  ;;                     (sis--ensure-dir
  ;;                      (call-process "/bin/bash" nil t nil "-c" (concat "im-select.exe " source)))))
  ;;  (setq sis-external-ism "im-select.exe"))
  ;; enable the /cursor color/ mode
  (sis-global-cursor-color-mode t)
  ;; enable the /respect/ mode
  (sis-global-respect-mode t)
  (sis-global-context-mode t)
  ;; enable the /follow context/ mode for all buffers
  ;; (sis-global-follow-context-mode t)
  ;; enable the /inline english/ mode for all buffers
  (sis-global-inline-mode t)
  )

;;  (setq sis-ism-lazyman-config "1033" "2052" 'im-select)
;;  (setq evil-default-cursor t))
;;
;;  ;; enable the /cursor color/ mode
;;  (setq sis-global-cursor-color-mode t)
;;  ;; enable the /respect/ mode
;;  (setq sis-global-respect-mode t)
;;  ;; enable the /follow context/ mode for all buffers
;;  (setq sis-global-follow-context-mode t)
;;  ;; enable the /inline english/ mode for all buffers
;;  (setq sis-global-inline-mode t)

;;(require 'init-evil) ; init-evil dependent on init-clipboard

;;(require-package 'rime)
;;(use-package rime
;;  :custom
;;  (rime-librime-root "~/.emacs.d/librime/dist")
;;  (default-input-method "rime")
;;  (rime-user-data-dir "~/Library/Rime")
;;  (rime-share-data-dir "~/Library/Rime")
;;  (setq rime-posframe-properties
;;        (list :font "sarasa ui sc"
;;              :internal-border-width 10))
;;  )
(setq org-plantuml-jar-path (expand-file-name "~/.emacs.d/plantuml.jar"))

;; 下面参考来源https://github.com/skuro/plantuml-mode
(setq plantuml-jar-path "~/.emacs.d/plantuml.jar")
(setq plantuml-default-exec-mode 'jar)
;;(setq plantuml-default-exec-mode 'executable)
(setq org-plantuml-exec-mode 'plantuml)
(setq org-plantuml-executable-path "~/bin/plantuml")
(setq org-plantuml-executable-args '("-headless" "-charset UTF-8"))

;; Enable plantuml-mode for PlantUML files
(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
;;(add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
;; 参考https://github.com/d12frosted/homebrew-emacs-plus/issues/383
;;(setq insert-directory-program "gls" dired-use-ls-dired t)
;;(setq dired-listing-switches "-al --group-directories-first")
;;(global-set-key (kbd "C-c o")
;;(lambda () (interactive) (find-file "~/organizer.org"))
(global-set-key (kbd "C-c o")
                (lambda () (interactive) (find-file "~/organizer.org")))
(set-register ?o (cons 'file "~/organizer.org"))
(setq org-default-notes-file "~/organizer.org")
;;hugo设置
(with-eval-after-load 'ox
  (require 'ox-hugo))
;;(custom-set-faces '(org-table ((t (:foreground "#a9a1e1" :height 120 :family "Noto Sans Mono CJK SC Regular")))))
(add-hook 'org-mode-hook (lambda () (setq toggle-truncate-lines t)))
(provide 'init-local)
