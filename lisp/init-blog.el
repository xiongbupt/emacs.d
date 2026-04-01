;;; init-blog.el --- Personal blog workflow with ox-hugo (single Org file) -*- lexical-binding: t; -*-
;; Author: dennis (@xiongbupt)
;; Keywords: org-mode, hugo, blogging
;;; Commentary:
;; Single-file blog workflow: blog.org → ox-hugo → Hugo → GitHub Pages
;; Key bindings (in org-mode):
;; C-c b o    Open blog.org
;; C-c b n    New draft post
;; C-c b e    Export current subtree
;; C-c b a    Export all publishable posts
;; C-c b p    Full publish pipeline
;; C-c b s    Start local Hugo server
;; C-c b S    Stop local Hugo server
;; C-c b i    Insert image
;;; Code:
;;; ─────────────────────────────────────────────
;;; 1. ox-hugo 安装与配置
;;; ─────────────────────────────────────────────
(use-package ox-hugo
  :ensure t
  :after ox
  :config
  (setq org-hugo-auto-set-lastmod t)
  (setq org-hugo-export-with-toc nil)
  (setq org-hugo-use-code-for-kbd t))

;;; ─────────────────────────────────────────────
;;; 2. 路径与参数配置（按需修改这里）
;;; ─────────────────────────────────────────────
(defvar my/blog-org-file
  (expand-file-name "~/Documents/blog/org_blog/all-post.org")
  "Single Org file containing all posts as subtrees.")

(defvar my/blog-hugo-dir
  (expand-file-name "~/Documents/blog/github_blog")
  "Hugo project root directory.")

(defvar my/blog-static-images-dir
  (expand-file-name "static/images/" my/blog-hugo-dir)
  "Hugo static images directory.")

(defvar my/blog-images-rel-path
  "/images/"
  "Site-relative image path prefix.")

(defvar my/blog-url
  "https://xiongbupt.github.io/"
  "Published blog URL for preview.")

;;; ─────────────────────────────────────────────
;;; 3. 内部工具函数
;;; ─────────────────────────────────────────────
(defun my/blog--run-command (command buffer-name &optional error-msg)
  "Run shell COMMAND, output to BUFFER-NAME. Return t on success."
  (with-current-buffer (get-buffer-create buffer-name)
    (erase-buffer))  ; 清空旧日志，避免累积
  (let ((exit-code (call-process-shell-command command nil buffer-name t)))
    (unless (zerop exit-code)
      (pop-to-buffer buffer-name)
      (user-error (or error-msg
                      (format "Command failed (exit %d): %s" exit-code command))))
    t))

(defun my/blog--ensure-dir (dir)
  "Create DIR if it does not exist."
  (unless (file-directory-p dir)
    (make-directory dir t)
    (message "Created directory: %s" dir)))

;;; ─────────────────────────────────────────────
;;; 4. 核心导出函数 + 自动导出模式
;;; ─────────────────────────────────────────────
(defun my/blog-export-all ()
  "Export all publishable subtrees from blog.org to Hugo Markdown.
Use :noexport: tag or :EXPORT_HUGO_DRAFT: true to control visibility."
  (interactive)
  (unless (file-exists-p my/blog-org-file)
    (user-error "Blog Org file not found: %s" my/blog-org-file))
  (with-current-buffer (find-file-noselect my/blog-org-file)
    (save-buffer)
    (org-hugo-export-wim-to-md t)
    (message "✅ Exported all publishable posts")))

(defun my/blog-export-current ()
  "Export only the subtree at point."
  (interactive)
  (unless (eq major-mode 'org-mode)
    (user-error "Must be in Org mode"))
  (org-hugo-export-wim-to-md)
  (message "✅ Exported current post"))

;; 自动导出模式：只在 blog.org 中启用，保存时只导出变更部分（性能关键）
(add-hook 'org-mode-hook
          (lambda ()
            (when (and (buffer-file-name)
                       (string= (file-name-nondirectory (buffer-file-name))
                                "all-post.org"))
              (org-hugo-auto-export-mode 1)
              (message "org-hugo-auto-export-mode enabled for all-post.org"))))

;;; ─────────────────────────────────────────────
;;; 5. Hugo 开发服务器管理
;;; ─────────────────────────────────────────────
(defvar my/blog--server-process nil
  "Hugo server process object.")

(defun my/blog-serve ()
  "Start Hugo dev server with drafts visible. Restart if already running."
  (interactive)
  (when (and my/blog--server-process (process-live-p my/blog--server-process))
    (if (y-or-n-p "Hugo server running. Restart? ")
        (my/blog-stop-server)
      (message "Hugo server still running at http://localhost:1313/")
      (cl-return-from my/blog-serve)))
  (let ((default-directory my/blog-hugo-dir))
    (setq my/blog--server-process
          (start-process "hugo-server" "*hugo-server*"
                         "hugo" "server" "-D" "--navigateToChanged"))
    (set-process-sentinel
     my/blog--server-process
     (lambda (proc event)
       (when (string-prefix-p "finished" event)
         (message "Hugo server stopped.")
         (setq my/blog--server-process nil))))
    (message "🌐 Hugo server started → http://localhost:1313/")))

(defun my/blog-stop-server ()
  "Stop Hugo dev server if running."
  (interactive)
  (if (and my/blog--server-process (process-live-p my/blog--server-process))
      (progn
        (delete-process my/blog--server-process)
        (setq my/blog--server-process nil)
        (message "🛑 Hugo server stopped."))
    (message "No Hugo server running.")))

;;; ─────────────────────────────────────────────
;;; 6. 完整发布流程（只在有变更时 commit）
;;; ─────────────────────────────────────────────
(defun my/blog-publish ()
  "Export → Build → Commit (only if changed) → Push."
  (interactive)
  (let ((commit-msg (format "Update blog: %s" (format-time-string "%Y-%m-%d %H:%M"))))
    ;; 1. 导出
    (message "Exporting Org → Markdown...")
    (my/blog-export-all)

    ;; 2. Hugo build
    (message "Building Hugo site...")
    (let ((default-directory my/blog-hugo-dir))
      (my/blog--run-command "hugo --minify --cleanDestinationDir"
                            "*hugo-build*"
                            "Hugo build failed"))

    ;; 3. Git commit & push（仅当有 staged 变更时 commit）
    (message "Committing and pushing...")
    (let ((default-directory my/blog-hugo-dir))
      (my/blog--run-command
       (format "git add -A && if ! git diff --cached --quiet; then git commit -m %s; else echo 'No changes to commit'; fi && git push"
               (shell-quote-argument commit-msg))
       "*blog-git*"
       "Git operation failed"))

    ;; 4. 如果 public/ 是 submodule，额外推送
    (let ((public-dir (expand-file-name "public/" my/blog-hugo-dir)))
      (when (file-exists-p (expand-file-name ".git" public-dir))
        (message "Pushing public/ submodule...")
        (let ((default-directory public-dir))
          (my/blog--run-command
           (format "git add -A && if ! git diff --cached --quiet; then git commit -m %s; fi && git push"
                   (shell-quote-argument commit-msg))
           "*blog-public-git*"
           "public/ push failed"))))

    (message "🚀 Published! Opening %s..." my/blog-url)
    (sit-for 1)
    (browse-url my/blog-url)))

;;; ─────────────────────────────────────────────
;;; 7. 图片插入（支持已有文件复用）
;;; ─────────────────────────────────────────────
(defun my/blog-insert-image ()
  "Insert local image: copy to static/images/, insert relative link."
  (interactive)
  (my/blog--ensure-dir my/blog-static-images-dir)
  (let* ((img-file (expand-file-name (read-file-name "Select image: " nil nil t)))
         (img-name (file-name-nondirectory img-file))
         (target (expand-file-name img-name my/blog-static-images-dir))
         (org-link (concat my/blog-images-rel-path img-name)))
    (if (file-exists-p target)
        (message "Image already exists: %s" img-name)
      (copy-file img-file target)
      (message "Copied %s → static/images/" img-name))
    (let ((desc (if (y-or-n-p "Add alt/caption? ")
                    (read-string "Alt text: ")
                  "")))
      (insert (if (string-empty-p desc)
                  (format "[[%s]]" org-link)
                (format "[[%s][%s]]" org-link desc))))
    (message "Inserted: %s" org-link)))

;;; ─────────────────────────────────────────────
;;; 8. 新文章创建（改进 slug 处理）
;;; ─────────────────────────────────────────────
(defun my/blog-new-post (title)
  "Create new post skeleton with :noexport: tag."
  (interactive "sPost title: ")
  (with-current-buffer (find-file my/blog-org-file)
    (goto-char (point-max))
    (unless (bolp) (insert "\n"))
    (let* ((slug-base (downcase (replace-regexp-in-string " " "-" title)))
           (slug (string-trim
                  (replace-regexp-in-string "[^a-z0-9-]+" "-" slug-base)
                  "-+" "-+"))
           (date (format-time-string "%Y-%m-%d")))
      (insert (format "\n* %s\t\t\t\t\t\t\t\t:noexport:\n" title))
      (insert ":PROPERTIES:\n")
      (insert (format ":EXPORT_FILE_NAME: %s\n" (or slug "untitled")))
      (insert (format ":EXPORT_DATE: %s\n" date))
      (insert ":EXPORT_HUGO_DRAFT: true\n")
      (insert ":END:\n\n")
      (insert "#+begin_description\n简短摘要（用于列表显示）\n#+end_description\n\n")
      (insert "正文从这里开始...\n"))
    (save-buffer)
    (message "New draft: \"%s\" (remove :noexport: to publish)" title)))


(defun my/org-download-for-blog-screenshot ()
  "为博客插入截图：保存到 blog.org 同级 static/images/，用 file: 相对路径（Org 可显示）"
  (interactive)
  (let* ((blog-dir (file-name-directory (or (buffer-file-name) default-directory)))
         (image-dir (expand-file-name "static/images" blog-dir)))
    (unless (file-directory-p image-dir)
      (make-directory image-dir t)
      (message "创建图片目录：%s" image-dir))
    (let ((org-download-image-dir image-dir)
          (org-download-link-format "[[file:%s]]"))
      (call-interactively 'org-download-screenshot))))

(defun my/org-download-for-blog-clipboard ()
  "为博客插入剪贴板图片，同上逻辑"
  (interactive)
  (let* ((blog-dir (file-name-directory (or (buffer-file-name) default-directory)))
         (image-dir (expand-file-name "static/images" blog-dir)))
    (unless (file-directory-p image-dir)
      (make-directory image-dir t))
    (let ((org-download-image-dir image-dir)
          (org-download-link-format "[[file:%s]]"))
      (call-interactively 'org-download-clipboard))))

;; 快捷键绑定
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c b d s") 'my/org-download-for-blog-screenshot)
  (define-key org-mode-map (kbd "C-c b d v") 'my/org-download-for-blog-clipboard))
;;; ─────────────────────────────────────────────
;;; 9. 快捷键绑定
;;; ─────────────────────────────────────────────
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c b o") #'my/blog-open-org)
  (define-key org-mode-map (kbd "C-c b n") #'my/blog-new-post)
  (define-key org-mode-map (kbd "C-c b e") #'my/blog-export-current)
  (define-key org-mode-map (kbd "C-c b a") #'my/blog-export-all)
  (define-key org-mode-map (kbd "C-c b p") #'my/blog-publish)
  (define-key org-mode-map (kbd "C-c b s") #'my/blog-serve)
  (define-key org-mode-map (kbd "C-c b S") #'my/blog-stop-server)
  (define-key org-mode-map (kbd "C-c b i") #'my/blog-insert-image))

(defun my/blog-open-org ()
  "Open main blog.org file."
  (interactive)
  (find-file my/blog-org-file))

(provide 'init-blog)
;;; init-blog.el ends here
