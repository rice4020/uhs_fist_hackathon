const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// Flutter 빌드 폴더 경로 설정 (Node.js 프로젝트 위치에 따라 경로 조정 필요)
const flutterBuildPath = path.join(__dirname, 'build', 'web');

// 정적 파일 제공
app.use(express.static(flutterBuildPath));

// JSON Body 파싱
app.use(express.json());

/// 데이터 베이스
const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: '1234', // 본인 MySQL 비밀번호로 변경
    database: 'study_together'
};

const dbPool = mysql.createPool(dbConfig);

async function initDatabase() {
    try {
        // 1. MySQL 서버 연결 (DB 없이)
        const connection = await mysql.createConnection({
            host: dbConfig.host,
            user: dbConfig.user,
            password: dbConfig.password
        });

        // 2. 데이터베이스 생성
        await connection.query(`CREATE DATABASE IF NOT EXISTS ${dbConfig.database}`);
        await connection.query(`USE ${dbConfig.database}`);
        console.log(`Database '${dbConfig.database}' is ready.`);

        // 3. 사용자 테이블 생성
        await connection.query(`
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(50) NOT NULL UNIQUE,
                auth_code VARCHAR(100) NOT NULL
            )
        `);
        console.log('Table "users" is ready.');

        // 4. 스터디 테이블 생성
        await connection.query(`
            CREATE TABLE IF NOT EXISTS studies (
                id INT AUTO_INCREMENT PRIMARY KEY,
                study_name VARCHAR(100) NOT NULL,
                target VARCHAR(100),
                weekday VARCHAR(20),
                start_time VARCHAR(20),
                end_time VARCHAR(20),
                location VARCHAR(200),
                requirements TEXT
            )
        `);
        console.log('Table "studies" is ready.');

        // 5. 스터디-사용자 연결 테이블 생성 (다대다)
        await connection.query(`
            CREATE TABLE IF NOT EXISTS study_participants (
                study_id INT NOT NULL,
                user_id INT NOT NULL,
                PRIMARY KEY (study_id, user_id),
                FOREIGN KEY (study_id) REFERENCES studies(id) ON DELETE CASCADE,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `);
        console.log('Table "study_participants" is ready.');

        await connection.end();
        console.log('Database initialization completed!');
    } catch (err) {
        console.error('MySQL initialization error:', err);
        process.exit(1); // DB 초기화 실패 시 종료
    }
}

///
/// api 모음들

app.post('/user/create', async (req, res) => {
    const { username, auth_code } = req.body;

    // 유효성 체크
    if (!username || !auth_code) {
        return res.status(400).json({ error: 'username과 auth_code가 필요합니다.' });
    }

    try {
        const [result] = await dbPool.execute(
            'INSERT INTO users (username, auth_code) VALUES (?, ?)',
            [username, auth_code]
        );

        // 삽입된 ID 반환
        res.status(200).json({
            id: result.insertId,
            username,
            auth_code
        });
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ error: '이미 존재하는 username입니다.' });
        }
        console.error(err);
        res.status(500).json({ error: 'DB 삽입 중 오류 발생' });
    }
});

// POST /user/check
app.post('/user/login', async (req, res) => {
    const { username, auth_code } = req.body;
    console.log("로그인 시도");
    // 요청값 유효성 체크
    if (!username || !auth_code) {
        return res.status(400).json({ error: 'username과 auth_code가 필요합니다.' });
    }

    try {
        // DB에서 username + auth_code 조회
        const [rows] = await dbPool.execute(
            'SELECT id FROM users WHERE username = ? AND auth_code = ?',
            [username, auth_code]
        );

        if (rows.length > 0) {
            // 존재함 → 200 OK
            res.status(200).json({ message: '사용자 존재' });
        } else {
            // 존재하지 않음 → 400
            res.status(400).json({ error: '사용자를 찾을 수 없음' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'DB 조회 중 오류 발생' });
    }
});

app.post('/study/create', async (req, res) => {
    const {
        study_name,
        target,
        weekday,
        start_time,
        end_time,
        location,
        requirements
    } = req.body;

    // 입력값 검증
    if (!study_name || !weekday || !start_time || !end_time || !location) {
        return res.status(400).json({
            error: "study_name, weekday, start_time, end_time, location 은 필수입니다."
        });
    }

    try {
        const sql = `
            INSERT INTO studies 
            (study_name, target, weekday, start_time, end_time, location, requirements)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `;

        const values = [
            study_name,
            target || null,
            weekday,
            start_time,
            end_time,
            location,
            requirements || null
        ];

        const [result] = await dbPool.execute(sql, values);

        res.status(200).json({
            message: "스터디 생성 성공",
            study_id: result.insertId,
            data: {
                study_name,
                target,
                weekday,
                start_time,
                end_time,
                location,
                requirements
            }
        });
    } catch (err) {
        console.error("스터디 생성 에러:", err);
        res.status(500).json({ error: "DB 삽입 중 오류 발생" });
    }
});

app.get('/study/list', async (req, res) => {
    try {
        const [rows] = await dbPool.execute("SELECT * FROM studies");

        return res.status(200).json({
            count: rows.length,
            studies: rows
        });
    } catch (err) {
        console.error("스터디 조회 중 오류:", err);
        return res.status(500).json({ error: "DB 조회 중 오류 발생" });
    }
});

///
// 모든 요청에 대해 index.html 제공 (Flutter 라우팅 처리용)
app.get('/', (req, res) => {
    res.sendFile(path.join(flutterBuildPath, 'index.html'));
});

app.get('/hello', (req, res) => {
    res.json({
        message: 'Hello from Node.js!'
    });
}); 

initDatabase().then(() => {
    app.listen(PORT, () => {
        console.log(`Server is running on http://localhost:${PORT}`);
    });
});
