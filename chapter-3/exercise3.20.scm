;                 +---------------------+
;                 |                     |
;                 |                  z:------->[o][o]
;                 |                     |       |  |
;     global-env: |                  +---------------------------------+
;                 |                  +------------------------------+  |
;                 |                  |  |       |  |                |  |
;                 |                  V  |       V  V                |  |
;  +-------------------------------> x:------->[o][o]---------+     |  | 
;  |              |set-car!: ...        |       |             |     |  | 
;  |              |cdr: ...             |<--+   |             |     |  | 
;  |              +---------------------+   |   |             |     |  | 
;  |                                        |   |             |     |  | 
;  |              +---------------------+   |   V             |     |  | 
;  |    set-car!: | new-value: 17       |   |   param: x, y   |     |  | 
;  |              | z:-+                |   |   body: ...     |     |  | 
;  |              +----|----------------+   |                 |     |  | 
;  |                   V                    |         +-------+     |  | 
;  |              +---------------------+   |         |             |  | 
;  |         cdr: | z:-+cdr             |   |         |             |  | 
;  |              +----|----------------+   |         |             |  | 
;  |                   |     ^              |         |             |  | 
;  +-------------------+     |              |         |             |  | 
;                            |              |         |             |  | 
;                            |              |         |             |  | 
;                 +---------------------+   |         |             |  | 
;       dispatch: | m: 'cdr             |   |         |             |  | 
;                 +---------------------+   |         |             |  | 
;                      ^                    |         V             |  |  
;                      |                    |   +---------------+   |  |   
;                 +---------------------+   |   | x: 1          |   |  |   
;       (z 'cdr): | y:-+                |   |   | y: 2          |   |  |   
;                 +----|----------------+   |   | dispatch: ... |   |  |   
;                      |                    |   +---------------+   |  |   
;                      |                    |                       |  |
;                      |                    |   +---------------+   |  |
;                      |                    +---| car:--------------+  |
;                      |                        +---------------+      |              
;                      |                                               |
;                      +-----------------------------------------------+
