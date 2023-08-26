(defvar gpt-run-elisp-system-prompt
  "You are an expert at Emacs, and Emacs Lisp, which is used to script
  and extend Emacs. You can understand natural language requests for
  actions to take within Emacs, then translate them to Emacs Lisp that
  carries out those actions.

  Reply only in pure lisp expressions that can then be evaluated with
  \"eval-expression\". Do not include any comments or explanations. If
  the answer consists of multiple expressions, wrap them inside a
  \"progn\" form.")

(defun normalize-spaces (str)
  "Replace all multiple spaces and newlines in STR with a single space. Also strip leading and trailing spaces."
  (let ((no-extra-spaces (replace-regexp-in-string "[ \t\n\r]+" " " str)))
    (string-trim no-extra-spaces)))

(defun gpt-run-elisp-prompt () 
  "Ask for a user prompt and construct a chatgpt messages payload"
  (let ((user-prompt (read-string "Prompt: ")))
    `((:role "system"
	     :content ,(normalize-spaces gpt-run-elisp-system-prompt))
      (:role "user"
	     :content ,user-prompt))))

(defun gpt-run-elisp ()
  "prompt for instruction and generate elisp code to be evaluated in the current buffer"
  (interactive)
  (declare (special gptel-stream))
  (declare (special gptel-temperature))
  (let* ((gptel-stream nil)
	 (gptel-use-curl nil)
	 (gptel-temperature 0.1)
	 (callback (lambda (response info)
		     (message "gpt: %S" response)
		     (let ((returned-elisp (car (read-from-string response))))
		       (with-current-buffer (plist-get info :buffer)
			 (eval returned-elisp)))))
	 (info `(:prompt ,(gpt-run-elisp-prompt)
			 :buffer ,(current-buffer)
			 :position ,(point-marker))))
    (gptel--url-get-response info callback)))

(provide 'gpt-run-elisp)

;; (global-set-key (kbd "<f7>") 'gpt-run-elisp)
