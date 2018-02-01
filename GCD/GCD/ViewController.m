//
//  ViewController.m
//  GCD
//
//  Created by 杨康 on 2017/12/5.
//  Copyright © 2017年 杨康. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    //1.创建串行队列(像个大炮管道，每个炮代表一个任务)
//    dispatch_queue_t serialQueue =dispatch_queue_create("com.myProject.queue1", DISPATCH_QUEUE_SERIAL);
//    //获取主队列(串行队列）这个队列比较特殊，因为需要一直运行 所以不能阻塞 一般没有在标记在哪个队列的，都是在主队列
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//
//    //2.创建并行队列（像根电线里面很多线，每根线代表一个任务）
//    dispatch_queue_t concurrentQueue=dispatch_queue_create("com.myProject.queue2", DISPATCH_QUEUE_CONCURRENT);
//    //获取全局队列（并行队列）
//    dispatch_queue_t globalQueue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//
//    //3.创建同步任务（堵塞）
//    dispatch_sync(serialQueue, ^{
//        //任务代码
//    });
//
//    //4.创建异步任务 并不一定会另外起线程
//    dispatch_async(concurrentQueue, ^{
//        //任务代码
//    });
    
    
    
    //串行队列不能有【任务1 同步线程 任务3】 这种结构 不然会造成死锁
    //同步操作和同步任务内部代码可以理解成两个部分，把同步理解成一个整体，内部不考虑，具体到同步时再考虑内部代码
    
    /*
     1
    dispatch_sync(anyQueue, ^{
       2
        //任务代码
    });
    */
    
    
    
    //针对于串行队列，dispatch_async函数在哪个线程执行并不影响dispatch_async内部的代码块在哪个线程执行（这和dispatch_sync函数不同），这取决于任务所在的串行队列，串行队列会根据任务进入的顺序安排同一个线程依次执行。所以，在想要回到主线程的时候，在任意线程调用上述代码就可以轻松的获取到主线程。dispatch_sync会根据当前是什么线程决定内部代码在哪个线程执行
    //开发常用
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //更新UI
//    });
    [self Action10];
    
}
-(void)Action10
{
    dispatch_group_t group=dispatch_group_create();
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"主线程：%@",[NSThread currentThread]);
    NSLog(@"主线程开始");
    
    dispatch_group_enter(group);
    dispatch_async(globalQueue, ^{
        NSLog(@"任务1执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(globalQueue, ^{
        NSLog(@"任务2执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"任务全部完成");
    });
    //主线程被阻塞了，当我们的两个任务都执行完毕过后才会打印主线程结束。
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"主线程结束");
    
    
    
    
}
-(void)Action9
{
   //9、调度组：dispatch_group
    //创建调度组
    dispatch_group_t group = dispatch_group_create();
    
    //获取全局队列
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    
    NSLog(@"主线程：%@",[NSThread currentThread]);
    NSLog(@"主线程开始");
    
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"任务1执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"任务2执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    
    
    
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"任务全部完成");
    });
    
    
    NSLog(@"主线程结束");
    
    
    
    
    
}
-(void)Action8
{
   //8、dispatch_apply 快速迭代
    dispatch_apply(6, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
        NSLog(@"%zu", i);
    });
}
-(void)Action7
{
    //7、dispatch_once 实现单例模式
//    static AnyObject obj =nil;
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //初始化
    });
    
}
-(void)Action6
{
    //6、dispatch_after 延时执行
    //NSObject的实例方法performSelector: withObject: afterDelay:，因为可以用cancelPreviousPerformRequestsWithTarget:等方法取消这个还没到时间的延时操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"延时了两秒");
    });
}
-(void)Action5
{
    //5、dispatch_barrier 栅栏
    //dispatch_barrier_sync和dispatch_barrier_async都会阻塞传入的队列，并且这个传入的队列不能是系统提供的主队列和全局队列，否则就失去了使用它们的意义，就和使用dispatch_async和dispatch_sync一样的效果了
    dispatch_queue_t concurrentQueue=dispatch_queue_create("com.myProject.queue2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"主线程：%@",[NSThread currentThread]);
    NSLog(@"主线程开始");
    
    
    dispatch_async(concurrentQueue, ^{
        NSLog(@"任务1执行 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"任务2执行 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    
    dispatch_barrier_sync(concurrentQueue, ^{
        NSLog(@"任务barrier执行 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"任务3执行 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    dispatch_async(concurrentQueue, ^{
        NSLog(@"任务4执行 %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    NSLog(@"主线程结束");
    
    
}
-(void)Action4
{
    //4、并行队列+异步任务
    //注意：并不是并行队列同时执行几个任务就会开辟几个线程，我们知道并行队列也是FIFO的取出任务来执行，所以有一种可能是：后面某个任务还没取出的时候，前面某个任务已经结束了，这时候并行队列就会复用前面那个已经结束任务所在的线程了。
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"主线程：%@", [NSThread currentThread]);
    
    NSLog(@"主线程开始");
    
    dispatch_async(globalQueue, ^{
        NSLog(@"任务1执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"任务2执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"任务3执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"任务4执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    
    NSLog(@"主线程结束");
}
-(void)Action3
{
  //3、并行队列+同步任务
    dispatch_queue_t globalQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"主线程：%@",[NSThread currentThread]);
    
    
    NSLog(@"主线程开始");
    
    
    dispatch_sync(globalQueue, ^{
        NSLog(@"任务1执行%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    
    
    
    dispatch_sync(globalQueue, ^{
        NSLog(@"任务2执行%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    
    
    NSLog(@"主线程结束");
}
-(void)Action2
{
    //2、串行队列+异步任务
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_queue_t serialQueue = dispatch_queue_create("com.myProject.queue2", DISPATCH_QUEUE_SERIAL);
    
    NSLog(@"主队列：%@ \n创建的串行队列：%@", mainQueue, serialQueue);
    NSLog(@"主线程：%@", [NSThread currentThread]);
    
    NSLog(@"主线程开始");
    
    dispatch_async(serialQueue, ^{
        NSLog(@"任务1执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    
    dispatch_async(serialQueue, ^{
        NSLog(@"任务2执行 %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:4];
    });
    
    NSLog(@"主线程结束");
}
-(void)Action1
{
    //1.串行队列+同步任务
    dispatch_queue_t mainQueue=dispatch_get_main_queue();
    dispatch_queue_t serialQueue=dispatch_queue_create("com.myProject.queue2", DISPATCH_QUEUE_SERIAL);
    NSLog(@"主队列：%@\n创建的串行队列：%@",mainQueue,serialQueue);
    NSLog(@"主线程：%@",[NSThread currentThread]);
    
    
    NSLog(@"主线程开始");
    
    
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务1执行%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    
    
    
    dispatch_sync(serialQueue, ^{
        NSLog(@"任务2执行%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:4.0];
    });
    
    
    NSLog(@"主线程结束");
}



@end
