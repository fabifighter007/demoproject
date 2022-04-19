(namespace "free")

(module poll GOVERNANCE
(defcap GOVERNANCE ()
  @doc " Give the admin full access to call and upgrade the module. "
  (enforce-keyset 'poll-admin)
)

  (defschema question-schema
    question:string
    options:[string]
  )

  (defschema result-schema
    count:integer
  )

  (defschema question-schema-v2
    question_id:string
    question:string
    host:string
    options_number:integer
    options:list
    total_answers:integer
    start:time
    end:time
  )

  (defschema answer-schema
    question_id:string
    answer:string
  )

  (deftable question-table:{question-schema})
  (deftable answer-table:{answer-schema})
  (deftable result-table:{result-schema})

  (defconst INITIATED "initiated")
  (defconst ASSIGNED "assigned")

  (defun add-question (id:string question:string options:[string])
    (enforce (> (length options) 1) "You have to enter at least two possible Options.")
    (enforce (< (length options) 11) "Maximum of Options is ten.")

    (insert question-table id {
      "question":question,
      "options":options
      })
  )



    (defun add-question-2  (id:string question:string options:[string])
    (enforce (> (length options) 1) "You have to enter at least two possible Options.")
    (enforce (< (length options) 11) "Maximum of Options is ten.")

    (insert question-table id {
      "question":question,
      "options":options
      })

      (map (init_new_count question) options)
    )



  (defun init_new_count (question:string answer:string)
    (insert result-table (result-key question answer) {
      "count":0
      })
  )

  (defun read_result (question:string answer:string)
    (read result-table (result-key question answer))
  )

  (defun read_options (question_id:string)
    (read question-table (question_id))
  )

  (defun increase_count (question:string answer:string)
  (with-read result-table (result-key question answer) {
    "count":= count
    }
    (update result-table (result-key question answer){
    "count": (+ count 1)
    }))
  )

  (defun add-answer (id:string question_id:string answer:string)
    (enforce (> (length answer) 0) "You have to enter your choice.")

    (with-read question-table question_id {
      "question":= question,
      "options":= options
      }
    (enforce (contains answer options) "Answer does not match with Options.")

    (insert answer-table id {
      "question_id":question_id,
      "answer":answer
      })

      (increase_count question answer)
    )
  )

  (defun result-key (question:string answer:string)
     "Make composite key from question and answer"
     (format "{}:{}" [question answer])
   )

   (defun info (input)
      (format "{}" [input])
    )


   (defun read-question (question_id)
    (read question-table question_id)
   )


   (defun read-results (question_id)
    (with-read question-table question_id {
        "question":=question,
        "options":= options
      }
;(f (read_options question_id))

      (let* ((results (map (read_result question) options))
      (question_options (read-question question_id))
      (entry {
        "question": (drop ["options"] question_options),
        "options": (drop ["question"] question_options),
        "result": results

      }))
    entry
)
      )
   )
)

(create-table question-table)
(create-table answer-table)
(create-table result-table)
