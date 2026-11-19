
const auditRecord = {
  user_id: "USER001",
  username: "testuser",
  action: "USER_LOGIN",
  entity: "User",
  entity_id: "USER001",
  details: {
    message: "User successfully logged in",
    source: "audit-record-script",
    environment: "development",
  },
};

async function createAuditRecord() {
  try {
    const response = await fetch("http://localhost:5001/api/audit", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(auditRecord),
    });

    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.message || "Failed to create audit record");
    }

    console.log("Audit record created successfully!");
    console.log(JSON.stringify(result.audit, null, 2));
  } catch (error) {
    console.error("Error creating audit record:", error.message);
  }
}

createAuditRecord();





// Step 5: How to add more records in the future
// Whenever you want to generate another record, open:
// Audit-Service/scripts/create-audit-record.js

// Change the values in the auditRecord object.

// For example, to demonstrate a product creation event:
// const auditRecord = {
//   user_id: "ADMIN001",
//   username: "admin",
//   action: "PRODUCT_CREATED",
//   entity: "Product",
//   entity_id: "PRODUCT001",
//   details: {
//     product_name: "Nike Air Max",
//     price: 150,
//     source: "admin-dashboard",
//   },
// };

// Save and execute the script again:
// node Audit-Service/scripts/create-audit-record.js