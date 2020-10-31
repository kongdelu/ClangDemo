//
//  ViewController.m
//  ClangDemo
//
//  Created by ios on 2020/10/31.
//

#import "ViewController.h"
#import <dlfcn.h>
#import <libkern/OSAtomic.h>
@interface ViewController ()
@property (nonatomic, strong) UIButton *btn;
@end

@implementation ViewController

+ (void)load {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = CGRectMake(80, 80, 80, 60);
    [self.btn setTitle:@"touch" forState:UIControlStateNormal];
    self.btn.backgroundColor = [UIColor redColor];
    [self.btn addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn];
}

- (void)buttonAction {
    //遍历出队
    while (true) {
        //offsetof 就是针对某个结构体找到某个属性相对这个结构体的偏移量
        SymbolNode * node = OSAtomicDequeue(&symboList, offsetof(SymbolNode, next));
        if (node == NULL) break;
        Dl_info info;
        dladdr(node->pc, &info);
        
        printf("%s \n",info.dli_sname);
    }
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

//void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//  if (!*guard) return;  // Duplicate the guard check.
//  //__builtin_return_address 它的作用其实就是去读取 x30 中所存储的要返回时下一条指令的地址 . 所以他名称叫做 __builtin_return_address . 换句话说 , 这个地址就是我当前这个函数执行完毕后 , 要返回到哪里去 .
//  void *PC = __builtin_return_address(0);
//  char PcDescr[1024];
//  //__sanitizer_symbolize_pc(PC, "%p %F %L", PcDescr, sizeof(PcDescr));
//  printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
//}



//void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//    if (!*guard) return;  // Duplicate the guard check.
//
//    void *PC = __builtin_return_address(0);
//    Dl_info info;
//    dladdr(PC, &info);
//
//    printf("fname=%s \nfbase=%p \nsname=%s\nsaddr=%p \n",info.dli_fname,info.dli_fbase,info.dli_sname,info.dli_saddr);
//
//    char PcDescr[1024];
//    printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
//}

//原子队列
static OSQueueHead symboList = OS_ATOMIC_QUEUE_INIT;
//定义符号结构体
typedef struct{
    void * pc;
    void * next;
}SymbolNode;

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    //调用 load 方法时 , __sanitizer_cov_trace_pc_guard 函数的参数 guard 是 0.
    //if (!*guard) return;  // Duplicate the guard check.
    void *PC = __builtin_return_address(0);
    SymbolNode * node = malloc(sizeof(SymbolNode));
    *node = (SymbolNode){PC,NULL};
    
    //入队
    // offsetof 用在这里是为了入队添加下一个节点找到 前一个节点next指针的位置
    OSAtomicEnqueue(&symboList, node, offsetof(SymbolNode, next));
}

@end
