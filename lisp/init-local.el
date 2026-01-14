;;; -*- lexical-binding: t; -*-
;; 1. 抑制 session 警告
(add-to-list 'warning-suppress-types '(files missing-lexbind-cookie))

;; 2. 彻底解决 corfu 警告：屏蔽该包的加载
(setq-default package-load-list '((corfu-terminal nil) t))

;;(org-latex-pdf-process '("xelatex -interaction nonstopmode %f" "xelatex -interaction nonstopmode %f"))
;; load solarized-theme
;; https://github.com/sellout/emacs-color-theme-solarized
(setq frame-background-mode 'dark)
(let ((basedir "~/.emacs.d/elpa-31.0/themes/"))
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

(when (eq system-type 'darwin)
  ;; 1. 设置默认字体（英文字体部分）
  ;; 推荐使用 macOS 自带的 Monaco 或 Menlo，它们对中文支持的兼容性最好
  (set-face-attribute 'default nil :family "Monaco" :height 140)

  ;; 2. 绑定中文字体
  (let ((zh-font (font-spec :family "PingFang SC")))
    ;; 涵盖汉字、标点、全角符号、注音符号等
    (dolist (charset '(han cjk-misc symbol bopomofo kana))
      (set-fontset-font t charset zh-font nil 'prepend)))

  ;; 3. 解决 Org-mode 标签及特殊 Face 的显示
  ;; 这一步非常重要，它让这些特殊位置也遵循全局的字体逻辑
  (with-eval-after-load 'org
    (set-face-attribute 'org-tag nil :family "PingFang SC" :weight 'normal :height 1.0))

  ;; 4. 优化中文缩放比例（可选）
  ;; 如果觉得中文相对于英文看起来太小，可以微调这个比例（1.2 表示放大 20%）
  (setq face-font-rescale-alist '(("PingFang SC" . 1.2))))

(defun my-setup-chinese-fonts ()
  (when (eq system-type 'darwin)
    ;; 1. 设置中文字体缩放比例 (1.1 表示放大 10%)
    ;; 放在函数内确保每次重加载都生效
    (set-face-attribute 'default nil :family "Monaco" :height 140)
    (setq face-font-rescale-alist '(("PingFang SC" . 1.2)))

    (let ((zh-font-name "PingFang SC"))
      ;; 2. 核心修复：遍历 粗体/常规、正体/斜体 的所有组合
      ;; 这样能彻底解决 HTML/Markdown/Org 中因为加粗导致的问号乱码
      (dolist (weight '(normal bold))
        (dolist (slant '(normal italic))
          ;; (let ((zh-font-spec (font-spec :family zh-font-name :weight weight :slant slant)))
          (let ((zh-font-spec (font-spec :family zh-font-name :weight weight :slant 'normal)))
            ;; 涵盖汉字、全角标点、符号、注音等
            (dolist (charset '(han cjk-misc symbol bopomofo kana))
              (set-fontset-font t charset zh-font-spec nil 'prepend))))))))

;; 立即执行
(my-setup-chinese-fonts)

;; 确保在打开新窗口（如 emacsclient）时也生效
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (with-selected-frame frame
              (my-setup-chinese-fonts))))
(provide 'init-local)
