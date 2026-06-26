# CS301_Assignment_2
Після застосування індексів, CTE та покращення плану виконання запиту загальний час виконання зменшився з 1072 ms до 483 ms
Стосовно покращення метрик не всі ідекси використовуються бо програма сама обирає чи є вони оптимальними для використання, а якщо я примусово їх вмикаю через SET enable_indexscan = ON; час трохи погіршується дусь до 750 ms 

befor optimisation 
Result  (cost=156249.36..156249.37 rows=1 width=96) (actual time=1054.911..1062.838 rows=1.00 loops=1)
  Buffers: shared hit=28045, temp read=5962 written=5982
  InitPlan 1
    ->  Aggregate  (cost=104716.80..104716.81 rows=1 width=32) (actual time=708.767..710.406 rows=1.00 loops=1)
          Buffers: shared hit=9351, temp read=5590 written=5609
          ->  Limit  (cost=104716.65..104716.67 rows=10 width=70) (actual time=708.762..710.401 rows=10.00 loops=1)
                Buffers: shared hit=9351, temp read=5590 written=5609
                ->  Sort  (cost=104716.65..104966.65 rows=100000 width=70) (actual time=708.760..710.398 rows=10.00 loops=1)
                      Sort Key: (count(o.order_id)) DESC
                      Sort Method: top-N heapsort  Memory: 27kB
                      Buffers: shared hit=9351, temp read=5590 written=5609
                      ->  Finalize GroupAggregate  (cost=68278.72..102555.68 rows=100000 width=70) (actual time=460.099..693.930 rows=99991.00 loops=1)
                            Group Key: c.id
                            Buffers: shared hit=9351, temp read=5590 written=5609
                            ->  Gather Merge  (cost=68278.72..100105.68 rows=240000 width=38) (actual time=460.079..613.367 rows=289057.00 loops=1)
                                  Workers Planned: 2
                                  Workers Launched: 2
                                  Buffers: shared hit=9351, temp read=5590 written=5609
                                  ->  Partial GroupAggregate  (cost=67278.70..71403.70 rows=100000 width=38) (actual time=395.166..503.028 rows=96352.33 loops=3)
                                        Group Key: c.id
                                        Buffers: shared hit=9351, temp read=5590 written=5609
                                        ->  Sort  (cost=67278.70..68320.37 rows=416667 width=34) (actual time=395.151..442.535 rows=333333.33 loops=3)
                                              Sort Key: c.id
                                              Sort Method: external merge  Disk: 16496kB
                                              Buffers: shared hit=9351, temp read=5590 written=5609
                                              Worker 0:  Sort Method: external merge  Disk: 14128kB
                                              Worker 1:  Sort Method: external merge  Disk: 14096kB
                                              ->  Hash Join  (cost=3278.04..16989.89 rows=416667 width=34) (actual time=12.817..228.734 rows=333333.33 loops=3)
                                                    Hash Cond: (o.product_id = p.product_id)
                                                    Buffers: shared hit=9337
                                                    ->  Parallel Hash Join  (cost=3229.54..15843.00 rows=416667 width=38) (actual time=12.404..172.647 rows=333333.33 loops=3)
                                                          Hash Cond: (o.client_id = c.id)
                                                          Buffers: shared hit=9259
                                                          ->  Parallel Seq Scan on opt_orders o  (cost=0.00..11519.67 rows=416667 width=24) (actual time=0.009..17.987 rows=333333.33 loops=3)
                                                                Buffers: shared hit=7353
                                                          ->  Parallel Hash  (cost=2494.24..2494.24 rows=58824 width=30) (actual time=12.153..12.154 rows=33333.33 loops=3)
                                                                Buckets: 131072  Batches: 1  Memory Usage: 7392kB
                                                                Buffers: shared hit=1906
                                                                ->  Parallel Seq Scan on opt_clients c  (cost=0.00..2494.24 rows=58824 width=30) (actual time=0.011..11.566 rows=100000.00 loops=1)
                                                                      Buffers: shared hit=1906
                                                    ->  Hash  (cost=36.00..36.00 rows=1000 width=4) (actual time=0.403..0.404 rows=1000.00 loops=3)
                                                          Buckets: 1024  Batches: 1  Memory Usage: 44kB
                                                          Buffers: shared hit=78
                                                          ->  Seq Scan on opt_products p  (cost=0.00..36.00 rows=1000 width=4) (actual time=0.156..0.293 rows=1000.00 loops=3)
                                                                Buffers: shared hit=78
  InitPlan 2
    ->  Aggregate  (cost=19367.68..19367.69 rows=1 width=32) (actual time=157.978..158.380 rows=1.00 loops=1)
          Buffers: shared hit=9337
          ->  Sort  (cost=19322.45..19329.99 rows=3015 width=70) (actual time=156.468..157.425 rows=9347.00 loops=1)
                Sort Key: (count(o_1.order_id)) DESC
                Sort Method: quicksort  Memory: 1096kB
                Buffers: shared hit=9337
                ->  Finalize HashAggregate  (cost=19027.60..19148.22 rows=3015 width=70) (actual time=150.407..155.063 rows=9347.00 loops=1)
                      Group Key: c_1.id
                      Filter: (count(o_1.order_id) > 1)
                      Batches: 1  Memory Usage: 1049kB
                      Rows Removed by Filter: 2
                      Buffers: shared hit=9337
                      ->  Gather  (cost=16657.59..18919.05 rows=21710 width=38) (actual time=139.350..144.371 rows=26301.00 loops=1)
                            Workers Planned: 2
                            Workers Launched: 2
                            Buffers: shared hit=9337
                            ->  Partial HashAggregate  (cost=15657.59..15748.05 rows=9046 width=38) (actual time=86.913..88.615 rows=8767.00 loops=3)
                                  Group Key: c_1.id
                                  Batches: 1  Memory Usage: 1049kB
                                  Buffers: shared hit=9337
                                  Worker 0:  Batches: 1  Memory Usage: 1049kB
                                  Worker 1:  Batches: 1  Memory Usage: 1049kB
                                  ->  Hash Join  (cost=2756.31..15469.13 rows=37692 width=34) (actual time=4.901..76.890 rows=31221.67 loops=3)
                                        Hash Cond: (o_1.product_id = p_1.product_id)
                                        Buffers: shared hit=9337
                                        ->  Parallel Hash Join  (cost=2707.81..15321.27 rows=37692 width=38) (actual time=4.558..70.880 rows=31221.67 loops=3)
                                              Hash Cond: (o_1.client_id = c_1.id)
                                              Buffers: shared hit=9259
                                              ->  Parallel Seq Scan on opt_orders o_1  (cost=0.00..11519.67 rows=416667 width=24) (actual time=0.007..15.994 rows=333333.33 loops=3)
                                                    Buffers: shared hit=7353
                                              ->  Parallel Hash  (cost=2641.29..2641.29 rows=5321 width=30) (actual time=4.495..4.496 rows=3116.67 loops=3)
                                                    Buckets: 16384  Batches: 1  Memory Usage: 736kB
                                                    Buffers: shared hit=1906
                                                    ->  Parallel Seq Scan on opt_clients c_1  (cost=0.00..2641.29 rows=5321 width=30) (actual time=0.007..11.015 rows=9350.00 loops=1)
                                                          Filter: ((name)::text ~~ 'A%'::text)
                                                          Rows Removed by Filter: 90650
                                                          Buffers: shared hit=1906
                                        ->  Hash  (cost=36.00..36.00 rows=1000 width=4) (actual time=0.333..0.333 rows=1000.00 loops=3)
                                              Buckets: 1024  Batches: 1  Memory Usage: 44kB
                                              Buffers: shared hit=78
                                              ->  Seq Scan on opt_products p_1  (cost=0.00..36.00 rows=1000 width=4) (actual time=0.094..0.225 rows=1000.00 loops=3)
                                                    Buffers: shared hit=78
  InitPlan 3
    ->  Aggregate  (cost=32164.85..32164.86 rows=1 width=32) (actual time=185.900..191.804 rows=1.00 loops=1)
          Buffers: shared hit=9357, temp read=372 written=373
          ->  Gather Merge  (cost=19977.52..30983.60 rows=94500 width=36) (actual time=161.285..181.005 rows=84676.00 loops=1)
                Workers Planned: 2
                Workers Launched: 2
                Buffers: shared hit=9357, temp read=372 written=373
                ->  Sort  (cost=18977.50..19075.93 rows=39375 width=36) (actual time=102.548..104.873 rows=28225.33 loops=3)
                      Sort Key: o_2.order_id
                      Sort Method: external merge  Disk: 2976kB
                      Buffers: shared hit=9357, temp read=372 written=373
                      Worker 0:  Sort Method: quicksort  Memory: 2394kB
                      Worker 1:  Sort Method: quicksort  Memory: 2565kB
                      ->  Parallel Hash Join  (cost=3047.88..15972.20 rows=39375 width=36) (actual time=9.531..94.936 rows=28225.33 loops=3)
                            Hash Cond: (o_2.client_id = c_2.id)
                            Buffers: shared hit=9343
                            ->  Hash Join  (cost=40.88..12658.93 rows=79167 width=30) (actual time=0.303..53.154 rows=56546.67 loops=3)
                                  Hash Cond: (o_2.product_id = p_2.product_id)
                                  Buffers: shared hit=7431
                                  ->  Parallel Seq Scan on opt_orders o_2  (cost=0.00..11519.67 rows=416667 width=24) (actual time=0.008..16.460 rows=333333.33 loops=3)
                                        Buffers: shared hit=7353
                                  ->  Hash  (cost=38.50..38.50 rows=190 width=14) (actual time=0.285..0.286 rows=190.00 loops=3)
                                        Buckets: 1024  Batches: 1  Memory Usage: 17kB
                                        Buffers: shared hit=78
                                        ->  Seq Scan on opt_products p_2  (cost=0.00..38.50 rows=190 width=14) (actual time=0.091..0.256 rows=190.00 loops=3)
                                              Filter: ((product_category)::text = 'Category2'::text)
                                              Rows Removed by Filter: 810
                                              Buffers: shared hit=78
                            ->  Parallel Hash  (cost=2641.29..2641.29 rows=29257 width=30) (actual time=9.106..9.107 rows=16701.67 loops=3)
                                  Buckets: 65536  Batches: 1  Memory Usage: 3712kB
                                  Buffers: shared hit=1906
                                  ->  Parallel Seq Scan on opt_clients c_2  (cost=0.00..2641.29 rows=29257 width=30) (actual time=0.018..15.148 rows=50105.00 loops=1)
                                        Filter: ((status)::text = 'active'::text)
                                        Rows Removed by Filter: 49895
                                        Buffers: shared hit=1906
Planning:
  Buffers: shared hit=33
Planning Time: 1.423 ms
Execution Time: 1072.931 ms




after 
Result  (cost=136493.81..136493.82 rows=1 width=96) (actual time=471.797..471.806 rows=1.00 loops=1)
  Buffers: shared hit=9338 read=1, temp read=1820 written=1148
  CTE filtered_orders
    ->  Hash Join  (cost=3747.55..24235.45 rows=94500 width=56) (actual time=36.205..262.323 rows=84676.00 loops=1)
          Hash Cond: (o.client_id = c.id)
          Buffers: shared hit=9329 read=1
          ->  Hash Join  (cost=36.37..20025.50 rows=190000 width=34) (actual time=0.525..171.407 rows=169640.00 loops=1)
                Hash Cond: (o.product_id = p.product_id)
                Buffers: shared hit=7379 read=1
                ->  Seq Scan on opt_orders o  (cost=0.00..17353.00 rows=1000000 width=28) (actual time=0.104..58.373 rows=1000000.00 loops=1)
                      Buffers: shared hit=7353
                ->  Hash  (cost=34.00..34.00 rows=190 width=14) (actual time=0.410..0.411 rows=190.00 loops=1)
                      Buckets: 1024  Batches: 1  Memory Usage: 17kB
                      Buffers: shared hit=26 read=1
                      ->  Bitmap Heap Scan on opt_products p  (cost=5.62..34.00 rows=190 width=14) (actual time=0.200..0.374 rows=190.00 loops=1)
                            Recheck Cond: ((product_category)::text = 'Category2'::text)
                            Heap Blocks: exact=26
                            Buffers: shared hit=26 read=1
                            ->  Bitmap Index Scan on idx_opt_product_category  (cost=0.00..5.58 rows=190 width=0) (actual time=0.150..0.150 rows=190.00 loops=1)
                                  Index Cond: ((product_category)::text = 'Category2'::text)
                                  Index Searches: 1
                                  Buffers: shared read=1
          ->  Hash  (cost=3089.47..3089.47 rows=49737 width=38) (actual time=35.529..35.530 rows=50105.00 loops=1)
                Buckets: 65536  Batches: 1  Memory Usage: 3894kB
                Buffers: shared hit=1950
                ->  Bitmap Heap Scan on opt_clients c  (cost=561.75..3089.47 rows=49737 width=38) (actual time=1.610..20.258 rows=50105.00 loops=1)
                      Recheck Cond: ((status)::text = 'active'::text)
                      Heap Blocks: exact=1906
                      Buffers: shared hit=1950
                      ->  Bitmap Index Scan on idx_opt_clients_status  (cost=0.00..549.32 rows=49737 width=0) (actual time=1.349..1.349 rows=50105.00 loops=1)
                            Index Cond: ((status)::text = 'active'::text)
                            Index Searches: 1
                            Buffers: shared hit=44
  InitPlan 2
    ->  Aggregate  (cost=101081.16..101081.17 rows=1 width=32) (actual time=404.963..404.965 rows=1.00 loops=1)
          Buffers: shared hit=9338 read=1, temp read=474 written=1147
          ->  Limit  (cost=101080.85..101080.88 rows=10 width=1056) (actual time=404.952..404.954 rows=10.00 loops=1)
                Buffers: shared hit=9338 read=1, temp read=474 written=1147
                ->  Sort  (cost=101080.85..101317.10 rows=94500 width=1056) (actual time=404.951..404.952 rows=10.00 loops=1)
                      Sort Key: (count(filtered_orders.order_id)) DESC
                      Sort Method: top-N heapsort  Memory: 26kB
                      Buffers: shared hit=9338 read=1, temp read=474 written=1147
                      ->  GroupAggregate  (cost=96912.49..99038.74 rows=94500 width=1056) (actual time=364.147..398.768 rows=40704.00 loops=1)
                            Group Key: filtered_orders.client_id, filtered_orders.name, filtered_orders.surname
                            Buffers: shared hit=9335 read=1, temp read=474 written=1147
                            ->  Sort  (cost=96912.49..97148.74 rows=94500 width=1052) (actual time=364.133..374.801 rows=84676.00 loops=1)
                                  Sort Key: filtered_orders.client_id, filtered_orders.name, filtered_orders.surname
                                  Sort Method: external merge  Disk: 3792kB
                                  Buffers: shared hit=9335 read=1, temp read=474 written=1147
                                  ->  CTE Scan on filtered_orders  (cost=0.00..1890.00 rows=94500 width=1052) (actual time=36.210..316.078 rows=84676.00 loops=1)
                                        Storage: Disk  Maximum Storage: 5383kB
                                        Buffers: shared hit=9329 read=1, temp written=672
  InitPlan 3
    ->  Aggregate  (cost=6924.67..6924.68 rows=1 width=32) (actual time=21.292..21.294 rows=1.00 loops=1)
          Buffers: temp read=673 written=1
          ->  GroupAggregate  (cost=6632.57..6846.29 rows=2850 width=1056) (actual time=18.201..20.628 rows=2344.00 loops=1)
                Group Key: filtered_orders_1.client_id, filtered_orders_1.name, filtered_orders_1.surname
                Filter: (count(filtered_orders_1.order_id) > 1)
                Rows Removed by Filter: 1511
                Buffers: temp read=673 written=1
                ->  Sort  (cost=6632.57..6653.94 rows=8549 width=1052) (actual time=18.190..18.522 rows=7874.00 loops=1)
                      Sort Key: filtered_orders_1.client_id, filtered_orders_1.name, filtered_orders_1.surname
                      Sort Method: quicksort  Memory: 607kB
                      Buffers: temp read=673 written=1
                      ->  CTE Scan on filtered_orders filtered_orders_1  (cost=0.00..2126.25 rows=8549 width=1052) (actual time=0.209..15.367 rows=7874.00 loops=1)
                            Filter: ((name)::text ~~ 'A%'::text)
                            Rows Removed by Filter: 76802
                            Storage: Disk  Maximum Storage: 5383kB
                            Buffers: temp read=673 written=1
  InitPlan 4
    ->  Aggregate  (cost=4252.50..4252.51 rows=1 width=32) (actual time=43.957..43.958 rows=1.00 loops=1)
          Buffers: temp read=673
          ->  CTE Scan on filtered_orders filtered_orders_2  (cost=0.00..1890.00 rows=94500 width=1154) (actual time=0.064..10.687 rows=84676.00 loops=1)
                Storage: Disk  Maximum Storage: 5383kB
                Buffers: temp read=673
Planning:
  Buffers: shared hit=430
Planning Time: 4.316 ms
Execution Time: 482.899 ms
