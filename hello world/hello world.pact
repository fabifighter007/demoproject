(define-keyset 'hello-admin (read-keyset 'hello-keyset))

(module hello 'hello-admin
  "Hello World Example!"

  (defschema hello-schema
    value:string)

  (deftable hellos:{hello-schema})

  (defun hello (value)
    (write hellos "name" {"value": value}))

  (defun greet ()
    (with-read hellos "name" {"value" := value}
    (format "Hey there, {}!" [value]))
  )
)

(create-table hellos)
(hello "Fabian")
(greet)
