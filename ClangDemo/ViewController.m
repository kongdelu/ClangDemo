//
//  ViewController.m
//  ClangDemo
//
//  Created by ios on 2020/10/31.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(80, 80, 80, 60);
    [btn setTitle:@"touch" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(methodOne) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)methodOne {
    NSLog(@"%s",__FUNCTION__);
}

- (void)methodTwo {
    NSLog(@"%s",__FUNCTION__);
}

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
  static uint64_t N;  // Counter for the guards.
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
  if (!*guard) return;  // Duplicate the guard check.
  //__builtin_return_address 它的作用其实就是去读取 x30 中所存储的要返回时下一条指令的地址 . 所以他名称叫做 __builtin_return_address . 换句话说 , 这个地址就是我当前这个函数执行完毕后 , 要返回到哪里去 .
  void *PC = __builtin_return_address(0);
  char PcDescr[1024];
  //__sanitizer_symbolize_pc(PC, "%p %F %L", PcDescr, sizeof(PcDescr));
  printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
}


@end
