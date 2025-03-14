;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Load the publishing system
(require 'ox-publish)
(require 'ox-tufte)

;; Load org-mode, to be able to evaluate the code blocks
(require 'org)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t))) ;; Ensure Emacs Lisp execution

(setq org-export-babel-evaluate t) ;; Allow code execution on export
(setq org-confirm-babel-evaluate nil) ;; Do not ask for confirmation before executing

;; Evaluate all Emacs Lisp source blocks first
(org-babel-map-src-blocks nil
  (when (string= "emacs-lisp" lang)
    (org-babel-execute-src-block)))

;; Performing variables initialization
;(load-file "func.el")
(org-babel-load-file "func.el")

;; Customize the HTML output
(setq org-html-validation-link t              ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head       "<link rel=\"stylesheet\" href=\"css/tufte.css\" type=\"text/css\" />"
      org-html-head-extra "<link rel=\"stylesheet\" href=\"css/ox-tufte.css\" type=\"text/css\" />"
      org-html-postamble t
      org-html-postamble-format '(("en" "<hr> <p class=\"footer\">©2009-2025 parsec.ro, CC BY &#8226; un site de Claudiu Tănăselia &#8226; Generated with %c</p>"))
      )
;; Since both html-head and html-head-extra are used, this is appended to html-extra
(setq org-html-head-extra
      (concat org-html-head-extra
              "<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.ico\" />"))

(defun my-org-export-enable-transclusion (backend)
  "Ensure that transcluded content is included before export."
  (when (member backend '(html tufte-html))  ;; Apply to HTML & Tufte HTML exports
    (org-transclusion-add-all)))

(add-hook 'org-export-before-processing-hook #'my-org-export-enable-transclusion)

;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory "./"
             :publishing-function 'org-tufte-publish-to-html
             :publishing-directory "./public"
             :with-author nil           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-toc nil              ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :html-preamble (with-temp-buffer
                            (insert-file-contents "templates/preamble.html")
                            (buffer-string))
             :with-title nil
             :time-stamp-file nil
             :exclude "\\(?:^drafts/.*\\.org\\|^.packages/.*\\.org\\)"
             :html-html5-fancy t
             :html-doctype "html5"
             )))

;; Generate the site output
(org-publish-all t)

(message "Build complete, deploying...")
(shell-command "rsync -avzh ~/Emacs/orgmode/websites/next-parsec/public/ parsecro@86.105.152.250:/home/parsecro/www" "*rsync-output*")
(message "Deploy complete!")


