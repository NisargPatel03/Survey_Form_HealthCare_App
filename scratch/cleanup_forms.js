const fs = require('fs');
const path = require('path');

const formsDir = path.join(__dirname, '../assets/forms');

function processForms() {
  const files = fs.readdirSync(formsDir);
  let updatedCount = 0;

  files.forEach(file => {
    if (!file.endsWith('.json')) return;
    const filePath = path.join(formsDir, file);
    let data;
    try {
      data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (e) {
      console.error(`Error reading ${file}:`, e);
      return;
    }

    let updated = false;

    if (data.sections) {
      data.sections.forEach(section => {
        if (section.section && section.section.toLowerCase().includes('evaluat')) {
          if (section.fields) {
            const originalLength = section.fields.length;
            // Keep only fields that are NOT static inputs like name, signature, date, place, remarks (because we handle remarks dynamically)
            section.fields = section.fields.filter(field => field.key === 'marks');
            if (section.fields.length !== originalLength) {
              updated = true;
            }
          }
        }
      });
    }

    if (updated) {
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
      console.log(`Updated ${file}`);
      updatedCount++;
    }
  });

  console.log(`Finished processing. Updated ${updatedCount} files.`);
}

processForms();
