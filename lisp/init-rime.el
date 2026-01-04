;;; init-rime.el  --- Custom configuration
;;; Commentary
(require-package 'rime)
(require 'posframe)
(use-package rime
  :custom
  (default-input-method "rime")
  (rime-emacs-module-header-root "/opt/homebrew/include")
  (rime-librime-root "/opt/homebrew/opt/librime")
                                        ;(rime-librime-root "~/.emacs.d/librime/dist")
                                        ;(rime-emacs-module-header-root "/opt/homebrew/Cellar/emacs-plus@29/29.4/include")
;;;  (rime-posframe-properties (list :background-color "#333333"
;;;                                  :foreground-color "#dcdccc"
;;;                                  :internal-border-width 10))
  (rime-disable-predicates '(rime-predicate-prog-in-code-p
                             rime-predicate-org-in-src-block-p
                             rime-predicate-org-latex-mode-p
                             rime-predicate-in-code-string-p))
  (rime-inline-predicates '(rime-predicate-space-after-cc-p ;;在中文字符且有空格之后
                            rime-predicate-current-uppercase-letter-p ;;将要输入的为大写字母时
                            ;;rime-predicate-current-input-punctuation-p ;; 当要输入的是符号时
                            rime-predicate-punctuation-after-space-cc-p ;; 当要在中文字符且有空格之后输入符号时
                            rime-predicate-punctuation-line-begin-p ;;在行首要输入符号时
                            ))
;;  (rime-show-candidate 'posframe)
  (default-input-method "rime")
  :config
  ;; (setq rime-disable-predicates
  ;;       '(
  ;;         ;; If cursor is in code.
  ;;         rime-predicate-prog-in-code-p
  ;;         ;; If the cursor is after a alphabet character.
  ;;         rime-predicate-after-alphabet-char-p
  ;;         ;; If input a punctuation after
  ;;         ;; a Chinese charactor with whitespace.
  ;;         rime-predicate-punctuation-after-space-cc-p
  ;;         rime-predicate-special-ascii-line-begin-p))
  ;; (setq rime-inline-predicates
  ;;       ;; If cursor is after a whitespace
  ;;       ;; which follow a non-ascii character.
  ;;       '(rime-predicate-space-after-cc-p
  ;;         ;; If the current charactor entered is a uppercase letter.
  ;;         rime-predicate-current-uppercase-letter-p))
;;; support shift-l, shift-r, control-l, control-r
                                        ;； (setq rime-inline-ascii-trigger 'shift-l)
  ;; ;; meow 进入 insert-mode，且是 org-mode 或
  ;; ;; telega-chat-mode 时，切换到 Rime。
  ;; (add-hook 'meow-insert-enter-hook
  ;;           (lambda() (when (derived-mode-p 'org-mode 'telega-chat-mode)
  ;;                       (set-input-method "rime"))))
  ;; ;; 退出 insert mode 时，恢复英文。
  ;; (add-hook 'meow-insert-exit-hook
  ;;           (lambda() (set-input-method nil)))
  (setq rime-user-data-dir "~/.emacs.d/Rime")
;;; support shift-l, shift-r, control-l, control-r
  (setq rime-inline-ascii-trigger 'shift-l)

  )

(defun rime-predicate-special-ascii-line-begin-p ()
  "If '/' or '#' at the beginning of the line."
  (and (> (point) (save-excursion (back-to-indentation) (point)))
       (let ((string (buffer-substring (point) (max (line-beginning-position) (- (point) 80)))))
         (string-match-p "^[\/#]" string))))
(require-package 'isearch-mb)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)

(isearch-mb-mode 1)
(setq-default
 ;; Show match count next to the minibuffer prompt
 isearch-lazy-count t
 ;; Don't be stingy with history; default is to keep just 16 entries
 search-ring-max 200
 regexp-search-ring-max 200
 isearch-regexp-lax-whitespace t
 ;; Swiper style: space matches any sequence of characters in a line.
 search-whitespace-regexp ".*?"
 ;; Alternative: space matches whitespace, newlines and punctuation.
 search-whitespace-regexp "\\W+")
;;(require-package 'websocket)
;;(add-to-list 'load-path "~/.emacs.d/lisp/deno-bridge")
;;(require 'deno-bridge)
;;(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/deno-bridge-jieba"))
;;(require 'deno-bridge-jieba)
(global-visual-line-mode 1)
(provide 'init-rime)
;;;;; init-rime.el ends here
