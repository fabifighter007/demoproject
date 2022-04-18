(define-keyset 'poll-admin (read-keyset 'poll-keyset))

(module poll 'poll-admin
  (defschema question-schema
    question:string
    answers_text:list
  )

  (defschema result-schema
    count:integer
  )

  (defschema question-schema-v2
    question_id:string
    question:string
    host:string
    possible_answers_number:integer
    answers_text:list
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

  (defun add-question (id:string question:string answer:[string])
    (enforce (> (length answer) 1) "You have to enter at least two possible answers.")
    (enforce (< (length answer) 11) "Maximum of answers is ten.")

    (insert question-table id {
      "question":question,
      "answers_text":answer
      })
;           (var (map (init_new_count ) (answer)))

  )



    (defun add-question-2  (id:string question:string answer:[string])
      (map (init_new_count question) answer)
    )



  (defun init_new_count (question:string answer:string)
    (insert result-table (question answer) {
      "count":0
      })
  )

  (defun add-answer (id:string question_id:string answer:string)
    (enforce (> (length answer) 0) "You have to enter your choice.")

    (with-read question-table question_id {
      "question":=question,
      "answer":=possible_answers
      }
    (enforce (contains answer possible_answers))
    )

    (insert answer-table id {
      "question_id":question_id,
      "answer":answer
      })
  )

  (defun inventory-key (loanId:string owner:[string])
     "Make composite key from OWNER and LoanId"
     (format "{}:{}" [loanId owner])
   )


   (defun read-question (question_id)
    (read question-table question_id)
   )
)

(create-table question-table)
(create-table answer-table)
(create-table result-table)
