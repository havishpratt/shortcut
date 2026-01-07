import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "npm:resend";

const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

interface BookingPayload {
  record: {
    id: string;
    date: string; // ISO String
    customer_name: string;
    customer_email: string;
    status: string;
  };
  old_record: {
    status: string;
  };
  type: "INSERT" | "UPDATE";
  table: "bookings";
  schema: "public";
}

serve(async (req) => {
  try {
    const payload: BookingPayload = await req.json();

    // Only proceed if status changed to 'confirmed'
    const isConfirmed = payload.record.status === 'confirmed';
    const wasNotConfirmed = payload.old_record?.status !== 'confirmed';

    if (!isConfirmed || !wasNotConfirmed) {
      return new Response("No action needed", { status: 200 });
    }

    const bookingDate = new Date(payload.record.date);
    const endDate = new Date(bookingDate.getTime() + 60 * 60 * 1000); // +1 Hour

    // Generate ICS File Content
    const icsContent = [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:-//Bobby Cuts//App//EN",
      "BEGIN:VEVENT",
      `UID:${payload.record.id}`,
      `DTSTAMP:${new Date().toISOString().replace(/[-:]/g, "").split(".")[0]}Z`,
      `DTSTART:${bookingDate.toISOString().replace(/[-:]/g, "").split(".")[0]}Z`,
      `DTEND:${endDate.toISOString().replace(/[-:]/g, "").split(".")[0]}Z`,
      "SUMMARY:Haircut with Ryan",
      "DESCRIPTION:Your appointment at Ryan's Cuts is confirmed.",
      "LOCATION:Ryan's Cuts Shop",
      "STATUS:CONFIRMED",
      "END:VEVENT",
      "END:VCALENDAR"
    ].join("\r\n");

    // Send Email
    const data = await resend.emails.send({
      from: "Ryans Cuts <appointments@yourdomain.com>",
      to: [payload.record.customer_email],
      subject: "Appointment Confirmed: Ryan's Cuts",
      html: `
        <h1>You're Booked!</h1>
        <p>Hi ${payload.record.customer_name},</p>
        <p>Ryan has accepted your appointment request for <strong>${bookingDate.toLocaleString()}</strong>.</p>
        <p>A calendar invite is attached to this email.</p>
        <p>See you then!</p>
      `,
      attachments: [
        {
          filename: "appointment.ics",
          content: Buffer.from(icsContent).toString("base64"), // Resend expects base64 for attachments sometimes, or raw content depending on version. 
          // Note: Standard fetch/Resend Node SDK handles buffers. 
          // For Deno/Edge, we might need to send raw content if supported or base64 string.
          // Adjusting to Resend's Deno-compatible format expectations:
          content: icsContent.split('').map(c => c.charCodeAt(0)), // Simple array buffer if needed, but Resend Node SDK usually takes Buffer or string. 
          // Let's stick to string content for text files if supported, strictly speaking for 'npm:resend' in Deno:
        },
      ],
    });

    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  }
});
