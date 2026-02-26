;;; -*- lexical-binding: t; -*-
;; 1. 抑制 session 警告
(add-to-list 'warning-suppress-types '(files missing-lexbind-cookie))

;; 2. 彻底解决 corfu 警告：屏蔽该包的加载
;;(setq-default package-load-list '((corfu-terminal nil) t))

;;(org-latex-pdf-process '("xelatex -interaction nonstopmode %f" "xelatex -interaction nonstopmode %f"))
;; load solarized-theme
;; https://github.com/sellout/emacs-color-theme-solarized
(setq frame-background-mode 'dark)
(let ((basedir "~/.emacs.d/elpa-30.2/themes/"))
  (dolist (f (directory-files basedir))
    (if (and (not (or (equal f ".") (equal f "..")))
             (file-directory-p (concat basedir f)))
        (add-to-list 'custom-theme-load-path (concat basedir f)))))
(load-theme 'sanityinc-solarized-dark t)


(require 'package)
;; 1. 强制重置禁用名单
(setq package-load-list '(all))
(setq package-ignored-packages nil)

;; 2. 针对 Emacs 30 的底层修复：强制清理被标记为 disabled 的内置/外部包缓存
(setq package--builtins (delq (assq 'tomelr package--builtins) package--builtins))
(setq package--builtins (delq (assq 'yasnippet package--builtins) package--builtins))

;; 3. 重新初始化
(package-initialize)

(set-face-attribute 'default nil :height 140)
(set-default 'truncate-lines t)
(require-package 'sis)
;;(require-package 'plantuml-mode)
(require-package 'use-package)
;;(require-package 'ox-hugo)
(require-package 'org-download)
(require-package 'company)
(require-package 'posframe)
(require-package 'which-key)
(require-package 'isearch-mb)
(require-package 'rime)


;; Drag-and-drop to `dired`
(add-hook 'dired-mode-hook 'org-download-enable)
(use-package yasnippet
  :ensure t
  :config
  (add-to-list 'yas-snippet-dirs "~/Dropbox/org/snippets") ;; 建议用 add-to-list
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

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
;;(setq org-plantuml-jar-path (expand-file-name "~/.emacs.d/plantuml.jar"))

;; 下面参考来源https://github.com/skuro/plantuml-mode
;;(setq plantuml-jar-path "~/.emacs.d/plantuml.jar")
;;(setq plantuml-default-exec-mode 'jar)
;;(setq plantuml-default-exec-mode 'executable)
;;(setq org-plantuml-exec-mode 'plantuml)
;;(setq org-plantuml-executable-path "~/bin/plantuml")
;;(setq org-plantuml-executable-args '("-headless" "-charset UTF-8"))

;; Enable plantuml-mode for PlantUML files
;;(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))
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
;;(with-eval-after-load 'ox
;;  (require 'ox-hugo))
;;(custom-set-faces '(org-table ((t (:foreground "#a9a1e1" :height 120 :family "Noto Sans Mono CJK SC Regular")))))
(add-hook 'org-mode-hook (lambda () (setq toggle-truncate-lines t)))
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist
             '("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
  "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

(with-eval-after-load 'markdown-mode
  (define-key markdown-mode-map (kbd "C-c C-e") #'markdown-do))
;; Add a rule to file-coding-system-alist to try a list of coding systems
;; for any file that doesn't match a more specific rule earlier in the list.
;; This effectively provides a preferred order for initial guessing.

;; (setq file-coding-system-alist
;;       '(
;;         (".*" . (ucs-bom utf-8 cp936 gb18030 big5 euc-jp euc-kr iso-8859-1))
;;         ))
(setq debug-on-error t)



(defun setup-chinese-font ()
  "根据系统类型设置中文字体，解决粗体、斜体导致的乱码及缩放问题。"
  (interactive)
  (cond
   ;; --- macOS 配置 ---
   ((eq system-type 'darwin)
    (let ((english-font "Monaco")
          (chinese-font "PingFang SC"))
      ;; 1. 设置英文字体
      (set-face-attribute 'default nil :family english-font :height 140)
      ;; 2. 设置中文字体缩放
      (setq face-font-rescale-alist '(("PingFang SC" . 1.1)))
      ;; 3. 为不同样式绑定中文字体
      (dolist (weight '(normal bold))
        (dolist (slant '(normal italic))
          ;; 注意：中文字体通常不支持真正斜体，这里强制映射到 normal 避免乱码
          (let ((zh-font-spec (font-spec :family chinese-font :weight weight :slant 'normal)))
            (dolist (charset '(han cjk-misc symbol bopomofo kana))
              (set-fontset-font t charset zh-font-spec nil 'prepend)))))))

   ;; --- Linux (飞腾/UOS) 配置 ---
   ((eq system-type 'gnu/linux)
    (let ((english-font "Source Code Pro")
          (chinese-font "Noto Sans CJK SC"))
      ;; 1. 设置英文字体
      (set-face-attribute 'default nil :family english-font :height 150)
      ;; 2. 设置中文字体缩放
      (setq face-font-rescale-alist '(("Noto Sans CJK SC" . 1.0)))
      ;; 3. 遍历样式组合
      (dolist (weight '(normal bold))
        (dolist (slant '(normal italic))
          (let ((zh-font-spec (font-spec :family chinese-font :weight weight :slant 'normal)))
            (dolist (charset '(han cjk-misc symbol bopomofo kana))
              (set-fontset-font t charset zh-font-spec nil 'prepend)))))))))

;; 1. 立即执行
(setup-chinese-font)

;; 2. 针对 emacsclient (Daemon) 模式的兼容
;; 使用 after-setting-font-hook 通常比 after-make-frame-functions 在处理字体时更稳定
(add-hook 'server-after-make-frame-hook 'setup-chinese-font)

(provide 'init-local)
