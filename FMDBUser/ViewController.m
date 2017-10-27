//
//  ViewController.m
//  FMDBUser
//
//  Created by liping on 2017/10/25.
//  Copyright © 2017年 xintiyan. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "FMDBMigrationManager.h"
#import "Migration.h"
@interface ViewController ()
@property (nonatomic, strong) FMDatabase *db;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建表
    [self createlistFmdb];

}



- (IBAction)reloadValues:(id)sender {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"fmdb.sqlite"];
    
    FMDBMigrationManager * manager=[FMDBMigrationManager managerWithDatabaseAtPath:dbPath migrationsBundle:[NSBundle mainBundle]];
    
    Migration * migration_1=[[Migration alloc]initWithName:@"新增USer表" andVersion:1 andExecuteUpdateArray:@[@"create table User(id integer primary key,name text,score real)"]];//从版本生升级到版本1创建一个User表 带有 name,age 字段
    
    
//    Migration * migration_2=[[Migration alloc]initWithName:@"USer表新增字段email" andVersion:2 andExecuteUpdateArray:@[@"alter table User add email text"]];//给User表添加email字段
    
    
    
    [manager addMigration:migration_1];
//    [manager addMigration:migration_2];
    
    BOOL resultState=NO;
    NSError * error=nil;
    if (!manager.hasMigrationsTable) {
        resultState=[manager createMigrationsTable:&error];
    }
    resultState=[manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
    [migration_1 migrateDatabase:self.db error:&error];
    
    if ([self.db open]) {
        //带有参数的插入SQL语句
   [self.db executeUpdateWithFormat:@"insert into User (id,name, score) values (%ld,%@, %f)",15118130757,@"梁亚海", 120.0];
        
        [self.db executeUpdateWithFormat:@"insert into User (id,name, score) values (%ld,%@, %f)",15060193253,@"旋涡鸣人", 99.0];
        [self.db executeUpdateWithFormat:@"insert into User (id,name, score) values (%ld,%@, %f)",13682631295,@"旋涡鸣人", 98.0];
        
    }
    [self.db close];
    
}






-(void)createlistFmdb{
    
    //拼接数据库的路径/Documents/fmdb.sqlite
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"fmdb.sqlite"];
    //数据库文件
    self.db = [FMDatabase databaseWithPath:dbPath];
    //连接数据库文件
    if ([self.db open]) {
        //创建表
        BOOL isSuccess = [self.db executeUpdate:@"create table if not exists Student (id integer primary key, name text, score real)"];
        if (!isSuccess) {
            NSLog(@"创建不成功==%@", [self.db lastError]);
        }
        NSLog(@"创建成功%@",dbPath);
    }
    //关闭数据库文件
    [self.db close];
}




- (IBAction)addlist:(id)sender {
    
    if ([self.db open]) {
        //带有参数的插入SQL语句
        BOOL isSuccess = [self.db executeUpdateWithFormat:@"insert into Student (id,name, score) values (%ld,%@, %f)",15118130757,@"梁亚海", 120.0];
        if (!isSuccess) {
            NSLog(@"插入数据失败:%@", [self.db lastError]);
        }
        
        [self.db executeUpdateWithFormat:@"insert into Student (id,name, score) values (%ld,%@, %f)",15060193253,@"旋涡鸣人", 99.0];
          [self.db executeUpdateWithFormat:@"insert into Student (id,name, score) values (%ld,%@, %f)",13682631295,@"旋涡鸣人", 98.0];

    }
    [self.db close];
  
}

//2.有条件的查/删/改: where; and; or
- (IBAction)getValues:(id)sender {
    
    if ([self.db open]) {
        //查询(executeQuery)
//        FMResultSet *resultSet = [self.db executeQuery:@"select * from Student"];//查询所有
//        FMResultSet *resultSet=[self.db executeQuery:@"select * from Student where id=15118130757"];//查询数据库某一条数据
   FMResultSet *resultSet=[self.db executeQuery:@"select * from Student where name='旋涡鸣人'and id=15060193253"];//查询数据库某一条数据 多增加一个条件
        //循环
        while ([resultSet next]) {
            //选择方法
            NSString *nameStr = [resultSet stringForColumn:@"name"];
            double score = [resultSet doubleForColumn:@"score"];
            NSLog(@"%@,%f",nameStr,score);
        }

    }
    
    [self.db close];
    
}
// 删除数据
- (IBAction)delegateValues:(id)sender {
    
    if ([self.db open]) {
        BOOL isSuccess = [self.db executeUpdate:@"delete from Student where id=13682631295"];
        if (!isSuccess) {
            NSLog(@"删除失败:%@", [self.db lastError]);
        }
    }
    [self.db close];
    
}

- (IBAction)changeValues:(id)sender {
    
    
    if ([self.db open]) {
        BOOL isSuccess = [self.db executeUpdate:@"update Student set score=1028 where id=15118130757"];
        if (!isSuccess) {
            NSLog(@"修改失败:%@", [self.db lastError]);
        }
    }
    [self.db close];
    
}

- (IBAction)addnews:(id)sender {
    
    if ([self.db open]) {
        //判断字段是否存在
        if (![self.db columnExists:@"age" inTableWithName:@"Student"]) {
            
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@",@"Student",@"age"];
            BOOL ret = [self.db executeUpdate:sql];
            if (ret  != YES) {
                NSLog(@"add albumName fail");
            }
        }
        [self.db close];
    }

}



@end
