#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach/mach_vm.h>
#import <string.h>
#define OFF_PLAYER_LIST 0x2C8
#define OFF_ITEM_LIST   0x378
#define OFF_STEP        0x18
#define OFF_PC          0x30
#define OFF_HP          0x304
#define OFF_IC          0x58
static uintptr_t 核心=0;
static uint64_t rq(uintptr_t a){uint64_t v=0;if(a)memcpy(&v,(void*)a,8);return v;}
static uint32_t rd(uintptr_t a){uint32_t v=0;if(a)memcpy(&v,(void*)a,4);return v;}
static float rf(uintptr_t a){float v=0;if(a)memcpy(&v,(void*)a,4);return v;}
static uintptr_t 搜(void){
  mach_port_t t=mach_task_self();vm_address_t a=0,s=0;mach_msg_type_number_t c=VM_REGION_BASIC_INFO_COUNT_64;vm_region_basic_info_data_64_t i;vm_region_flavor_t f=VM_REGION_BASIC_INFO_64;
  for(;;){if(mach_vm_region(t,&a,&s,f,(vm_region_info_t)&i,&c,MACH_PORT_NULL)!=KERN_SUCCESS)break;
    if(i.protection&VM_PROT_READ){for(vm_address_t o=0;o+0x400<=s;o+=4){if(rf(a+o)==3.5f&&rf(a+o+4)==5.0f&&rd(a+o-0x380)==2)return a+o;}}
    a+=s;s=0;c=VM_REGION_BASIC_INFO_COUNT_64;if(a==0)break;}return 0;}
struct E{float x,y,z;int hp;};
static void 读P(struct E* o,int* n){*n=0;if(!核心)return;uint64_t L=rq(核心-OFF_PLAYER_LIST);if(!L)return;for(int i=0;i<12&&*n<40;i++){uint64_t e=rq(L+i*OFF_STEP);if(!e)continue;float x=rf(e+OFF_PC);int h=rd(e+OFF_HP);if(h==112&&x>0.5f){o[*n].x=x;o[*n].y=rf(e+OFF_PC+4);o[*n].z=rf(e+OFF_PC+8);o[*n].hp=h;(*n)++;}}}
static void 读I(struct E* o,int* n){*n=0;if(!核心)return;uint64_t L=rq(核心-OFF_ITEM_LIST);if(!L)return;for(int i=0;i<40&&*n<80;i++){uint64_t e=rq(L+i*OFF_STEP);if(!e)continue;float x=rf(e+OFF_IC);int h=rd(e+OFF_HP);if((h==112||h==105)&&(x>0.5f||h==105)){o[*n].x=x;o[*n].y=rf(e+OFF_IC+4);o[*n].z=rf(e+OFF_IC+8);o[*n].hp=h;(*n)++;}}}
@interface V:UIView@end
static V* ov=nil;
@implementation V
-(void)drawRect:(CGRect)r{[super drawRect:r];if(!核心)核心=搜();if(!核心)return;CGContextRef c=UIGraphicsGetCurrentContext();if(!c)return;CGSize sz=self.bounds.size;float cx=sz.width/2,cy=sz.height/2;
  void(^dp)(struct E,UIColor*)=^(struct E e,UIColor* col){float sx=cx+e.x*8,sy=cy+e.z*8;if(sx<0||sx>sz.width||sy<0||sy>sz.height)return;[col setFill];CGContextFillRect(c,CGRectMake(sx-4,sy-4,8,8));[[UIColor blackColor]setFill];CGContextFillRect(c,CGRectMake(sx-12,sy-12,24,2));[col setFill];CGContextFillRect(c,CGRectMake(sx-12,sy-12,24*(e.hp/112.0f),2));};
  struct E P[40],I[80];int np=0,ni=0;读P(P,&np);读I(I,&ni);
  for(int i=0;i<np;i++)dp(P[i],[UIColor greenColor]);
  for(int i=0;i<ni;i++)dp(I[i],(I[i].hp==105)?[UIColor redColor]:[UIColor orangeColor]);}
@end
__attribute__((constructor))static void 入(void){@autoreleasepool{dispatch_after(dispatch_time(DISPATCH_TIME_NOW,4*NSEC_PER_SEC),dispatch_get_main_queue(),^{UIWindow*w=nil;for(UIWindow*x in UIApplication.sharedApplication.windows){if(x.windowLevel==UIWindowLevelNormal){w=x;break;}}if(!w)return;ov=[[V alloc]initWithFrame:w.bounds];ov.backgroundColor=[UIColor clearColor];ov.userInteractionEnabled=NO;[w addSubview:ov];[NSTimer scheduledTimerWithTimeInterval:0.1 target:ov selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];});}}
