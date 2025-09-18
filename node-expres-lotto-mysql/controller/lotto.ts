import express from "express";
import { conn } from "../dbconnect";

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
  const numbers: string[] = req.body.numbers;

  // ตรวจสอบข้อมูลที่ส่งมา
  if (!numbers || !Array.isArray(numbers) || numbers.length === 0) {
    return res.status(400).json({ success: false, message: "ไม่มีเลขที่ส่งมา" });
  }

  // map ตัวเลข => [number, status]
  const values = numbers.map(num => [num, 0]); // status เริ่มต้น = 0
  const sql = "INSERT INTO lotto_name (number, status) VALUES ?";

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
  const sql = "SELECT fullname, phone,balance ,role FROM customer WHERE idx = ?";  // ใช้ idx แทน id

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



