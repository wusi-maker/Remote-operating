// MongoDB REST API 服务
// 这是一个简单的Node.js服务，用于为Qt应用提供MongoDB数据查询接口
// 需要安装: npm install express mongodb cors

const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');

const app = express();
const port = 3000;

// 启用CORS以允许Qt应用访问
app.use(cors());
app.use(express.json());

// MongoDB连接配置
const MONGO_URI = 'mongodb://sensor_user:sensor_password_123@47.111.21.77:27017/';
const DATABASE_NAME = 'sensor_data';
const COLLECTION_NAME = 'sensor_readings';

let db = null;
let collection = null;

// 连接MongoDB
async function connectToMongoDB() {
    try {
        const client = new MongoClient(MONGO_URI);
        await client.connect();
        db = client.db(DATABASE_NAME);
        collection = db.collection(COLLECTION_NAME);
        console.log('成功连接到MongoDB');
        console.log(`数据库: ${DATABASE_NAME}, 集合: ${COLLECTION_NAME}`);
    } catch (error) {
        console.error('MongoDB连接失败:', error);
        process.exit(1);
    }
}

// 获取最新数据的API端点
app.get('/api/latest-data', async (req, res) => {
    try {
        const { database, collection: collectionParam } = req.query;
        
        // 如果请求中指定了不同的数据库或集合，可以动态切换
        let targetCollection = collection;
        if (database && collectionParam) {
            targetCollection = db.collection(collectionParam);
        }
        
        // 查询最新的一条数据（按时间戳降序排列）
        const latestData = await targetCollection
            .findOne(
                {}, // 查询条件（空表示查询所有）
                { 
                    sort: { timestamp: -1 } // 按时间戳降序排列
                }
            );
        
        if (latestData) {
            console.log('返回最新数据:', new Date().toISOString());
            res.json(latestData);
        } else {
            console.log('未找到数据');
            res.status(404).json({ error: '未找到数据' });
        }
        
    } catch (error) {
        console.error('查询数据时出错:', error);
        res.status(500).json({ error: '服务器内部错误', details: error.message });
    }
});

// 获取指定时间之后的数据
app.get('/api/data-since', async (req, res) => {
    try {
        const { since, database, collection: collectionParam } = req.query;
        
        if (!since) {
            return res.status(400).json({ error: '缺少since参数' });
        }
        
        let targetCollection = collection;
        if (database && collectionParam) {
            targetCollection = db.collection(collectionParam);
        }
        
        // 查询指定时间之后的数据
        const sinceDate = new Date(since);
        const newData = await targetCollection
            .find(
                { timestamp: { $gt: sinceDate } },
                { sort: { timestamp: -1 }, limit: 1 }
            )
            .toArray();
        
        if (newData.length > 0) {
            console.log('返回新数据:', newData.length, '条');
            res.json(newData[0]); // 返回最新的一条
        } else {
            res.status(204).json({ message: '没有新数据' });
        }
        
    } catch (error) {
        console.error('查询数据时出错:', error);
        res.status(500).json({ error: '服务器内部错误', details: error.message });
    }
});

// 插入测试数据的API端点
app.post('/api/test-data', async (req, res) => {
    try {
        const testData = {
            timestamp: new Date(),
            imu: {
                orientation: {
                    x: Math.random() * 2 - 1,
                    y: Math.random() * 2 - 1,
                    z: Math.random() * 2 - 1,
                    w: Math.random() * 2 - 1
                },
                angular_velocity: {
                    x: Math.random() * 10 - 5,
                    y: Math.random() * 10 - 5
                },
                linear_acceleration: {
                    x: Math.random() * 20 - 10,
                    y: Math.random() * 20 - 10
                }
            },
            vehicle: {
                rpm: Math.random() * 3000 + 1000,
                steering_angle: Math.random() * 60 - 30,
                longitudinal_velocity: Math.random() * 50,
                lateral_velocity: Math.random() * 10 - 5
            },
            odometry: {
                pose: {
                    x: Math.random() * 1000,
                    y: Math.random() * 1000
                }
            },
            gps: {
                latitude: 39.9042 + (Math.random() - 0.5) * 0.01,
                longitude: 116.4074 + (Math.random() - 0.5) * 0.01
            }
        };
        
        const result = await collection.insertOne(testData);
        console.log('插入测试数据:', result.insertedId);
        res.json({ success: true, id: result.insertedId, data: testData });
        
    } catch (error) {
        console.error('插入数据时出错:', error);
        res.status(500).json({ error: '服务器内部错误', details: error.message });
    }
});

// 健康检查端点
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        database: DATABASE_NAME,
        collection: COLLECTION_NAME
    });
});

// 启动服务器
async function startServer() {
    await connectToMongoDB();
    
    app.listen(port, () => {
        console.log(`MongoDB REST API服务运行在 http://localhost:${port}`);
        console.log('可用的API端点:');
        console.log(`  GET  /api/latest-data     - 获取最新数据`);
        console.log(`  GET  /api/data-since      - 获取指定时间之后的数据`);
        console.log(`  POST /api/test-data       - 插入测试数据`);
        console.log(`  GET  /api/health          - 健康检查`);
        
        // 每5秒自动插入一条测试数据
        setInterval(async () => {
            try {
                const testData = {
                    timestamp: new Date(),
                    imu: {
                        orientation: {
                            x: Math.random() * 2 - 1,
                            y: Math.random() * 2 - 1,
                            z: Math.random() * 2 - 1,
                            w: Math.random() * 2 - 1
                        },
                        angular_velocity: {
                            x: Math.random() * 10 - 5,
                            y: Math.random() * 10 - 5
                        },
                        linear_acceleration: {
                            x: Math.random() * 20 - 10,
                            y: Math.random() * 20 - 10
                        }
                    },
                    vehicle: {
                        rpm: Math.random() * 3000 + 1000,
                        steering_angle: Math.random() * 60 - 30,
                        longitudinal_velocity: Math.random() * 50,
                        lateral_velocity: Math.random() * 10 - 5
                    },
                    odometry: {
                        pose: {
                            x: Math.random() * 1000,
                            y: Math.random() * 1000
                        }
                    },
                    gps: {
                        latitude: 39.9042 + (Math.random() - 0.5) * 0.01,
                        longitude: 116.4074 + (Math.random() - 0.5) * 0.01
                    }
                };
                
                await collection.insertOne(testData);
                console.log('自动插入测试数据:', new Date().toISOString());
            } catch (error) {
                console.error('自动插入数据失败:', error);
            }
        }, 5000); // 每5秒插入一次
    });
}

startServer().catch(console.error);

// 优雅关闭
process.on('SIGINT', () => {
    console.log('\n正在关闭服务器...');
    process.exit(0);
});