import express from "express";
import { conn } from "../dbconnect";
import { ResultSetHeader } from "mysql2";

export const router = express.Router();

// Middleware สำคัญ ต้องมีใน main app.ts ด้วย: app.use(express.json());

// ทดสอบ API
router.get("/", (req, res) => {
  res.send("API Lotto route OK ✅");
});

// ดึงข้อมูลล็อตโต้ทั้งหมด
router.get("/all", (req, res) => {
  const sql = "SELECT * FROM lotto_name";  // เปลี่ยนชื่อ table เป็น lotto_name
  conn.query(sql, (err, results: any) => {
    if (err) {
      console.error("DB ERROR:", err);
      return res.status(500).json({ success: false, message: "เกิดข้อผิดพลาดในระบบ" });
    }
    res.json({
      success: true,
      data: results,
    });
  });
});

// ลบข้อมูลล็อตโต้ทั้งหมด
router.delete("/delete", (req, res) => {
  const sql = "DELETE FROM lotto_name";  // ลบข้อมูลทั้งหมด

  conn.query(sql, (err, results: any) => {
    if (err) {
      console.error("DB ERROR:", err);
      return res.status(500).json({ success: false, message: `ไม่สามารถลบข้อมูลได้: ${err.message}` });
    }

    res.json({
      success: true,
      message: `ลบข้อมูลล็อตโต้ทั้งหมดเรียบร้อยแล้ว (${results.affectedRows} แถว)`,
    });
  });
});

// เพิ่มเลขล็อตโต้หลายตัวพร้อมกัน
router.post("/insert", (req, res) => {
  const numbers: {lottoID: number, number: string}[] = req.body.numbers;

  // ตรวจสอบข้อมูลที่ส่งมา
  if (!numbers || !Array.isArray(numbers) || numbers.length === 0) {
    return res.status(400).json({ success: false, message: "ไม่มีเลขที่ส่งมา" });
  }

  // map ตัวเลข => [lottoID, number, status]
  const values = numbers.map(num => [num.lottoID, num.number, 0]); // status เริ่มต้น = 0

  const sql = "INSERT INTO lotto_name (lottoID, number, status) VALUES ?";

  conn.query(sql, [values], (err, results: any) => {
    if (err) {
      console.error("DB ERROR:", err);
      // แสดงข้อความผิดพลาดจากการ query
      return res.status(500).json({ success: false, message: `เพิ่มข้อมูลไม่สำเร็จ: ${err.message}` });
    }
    res.json({
      success: true,
      message: "เพิ่มข้อมูลสำเร็จ",
      inserted: results.affectedRows,
    });
  });
});


// ดึงข้อมูลสมาชิกตาม id (userId)
router.get("/customer/:userId", (req, res) => {
  const userId = req.params.userId; // ดึง userId จาก params
  const sql = "SELECT fullname, phone, balance,role FROM customer WHERE idx = ?";  // ใช้ idx แทน id

  conn.query(sql, [userId], (err, results: any) => {
    if (err) {
      console.error("DB ERROR:", err);
      return res.status(500).json({ success: false, message: "เกิดข้อผิดพลาดในระบบ" });
    }

    if (results.length === 0) {
      return res.status(404).json({ success: false, message: "ไม่พบข้อมูลสมาชิก" });
    }

    res.json({
      success: true,
      data: results[0], // ส่งข้อมูลสมาชิกกลับ
    });
  });
});


// เพิ่ม route สำหรับอัพเดต status ของเลขล็อตโต้ที่เลือก
router.put("/update-status", (req, res) => {
  const selectedNumbers = req.body.selectedNumbers; // รับหมายเลขล็อตโต้ที่เลือกจาก client
  if (!selectedNumbers || selectedNumbers.length === 0) {
    return res.status(400).json({ success: false, message: "กรุณาระบุหมายเลขล็อตโต้ที่เลือก" });
  }

  const updatePromises = selectedNumbers.map((number: any) => {
    const sql = "UPDATE lotto_name SET status = 1 WHERE number = ?"; // สั่งให้ status เปลี่ยนเป็น 1 สำหรับหมายเลขที่เลือก
    return new Promise((resolve, reject) => {
      conn.query(sql, [number], (err, result) => {
        if (err) {
          reject(err); // ถ้ามีข้อผิดพลาดให้ reject
        } else {
          resolve(result); // ถ้าทำสำเร็จให้ resolve
        }
      });
    });
  });

  // รอให้การอัพเดตเสร็จสิ้น
  Promise.all(updatePromises)
    .then(() => {
      res.json({ success: true, message: "อัพเดตสถานะเรียบร้อย" });
    })
    .catch((err) => {
      console.error("Error updating status:", err);
      res.status(500).json({ success: false, message: "ไม่สามารถอัพเดตสถานะได้" });
    });
});

// เพิ่ม route สำหรับอัพเดต owner และ status ของเลขล็อตโต้ที่เลือก
router.put("/update-owner", (req, res) => {
  const selectedNumbers = req.body.selectedNumbers; // รับหมายเลขล็อตโต้ที่เลือกจาก client
  const userId = req.body.userId; // รับ userId จาก request
  const status = req.body.status; // รับ status จาก request

  if (!selectedNumbers || selectedNumbers.length === 0 || !userId || status === undefined) {
    return res.status(400).json({ success: false, message: "กรุณาระบุหมายเลขล็อตโต้ที่เลือกและ userId และ status" });
  }

  const updatePromises = selectedNumbers.map((number: any) => {
    const sql = "UPDATE lotto_name SET owner = ?, status = ? WHERE number = ?"; // อัพเดต owner และ status
    return new Promise((resolve, reject) => {
      conn.query(sql, [userId, status, number], (err, result) => {
        if (err) {
          reject(err); // ถ้ามีข้อผิดพลาดให้ reject
        } else {
          resolve(result); // ถ้าทำสำเร็จให้ resolve
        }
      });
    });
  });

  // รอให้การอัพเดตเสร็จสิ้น
  Promise.all(updatePromises)
    .then(() => {
      res.json({ success: true, message: "อัพเดตเจ้าของเลขล็อตโต้และสถานะเรียบร้อย" });
    })
    .catch((err) => {
      console.error("Error updating owner and status:", err);
      res.status(500).json({ success: false, message: "ไม่สามารถอัพเดตเจ้าของเลขล็อตโต้และสถานะได้" });
    });
});

router.get("/buy_al", (req, res) => {
  const userId = req.query.userId; // รับ userId จาก query parameter
  const sql = "SELECT * FROM lotto_name WHERE owner = ?";  // กรองเฉพาะที่ owner ตรงกับ userId
  
  conn.query(sql, [userId], (err, results) => {
    if (err) {
      console.error("DB ERROR:", err);
      return res.status(500).json({ success: false, message: "เกิดข้อผิดพลาดในระบบ" });
    }
    
    // ส่งข้อมูลที่กรองมาแล้วกลับไป
    res.json({
      success: true,
      data: results,
    });
  });
});

