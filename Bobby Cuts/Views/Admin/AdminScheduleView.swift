import SwiftUI

struct AdminScheduleView: View {
    @EnvironmentObject var adminVM: AdminViewModel

    private static let dayNames = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                Text("Weekly Schedule")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                if adminVM.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(sortedSchedule, id: \.dayOfWeek) { schedule in
                                ScheduleDayCard(schedule: schedule)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var sortedSchedule: [WeeklySchedule] {
        // Show all 7 days, filling in missing ones as inactive
        (1...7).map { day in
            adminVM.weeklySchedule.first(where: { $0.dayOfWeek == day })
            ?? WeeklySchedule(id: nil, dayOfWeek: day, startHour: 16, endHour: 20, isActive: false)
        }
    }

    @ViewBuilder
    private func ScheduleDayCard(schedule: WeeklySchedule) -> some View {
        var mutableSchedule = schedule

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(Self.dayNames[schedule.dayOfWeek])
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { schedule.isActive },
                    set: { newValue in
                        mutableSchedule.isActive = newValue
                        Task { await adminVM.updateScheduleDay(mutableSchedule) }
                    }
                ))
                .tint(AppTheme.accent)
            }

            if schedule.isActive {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textMuted)
                        Picker("Start", selection: Binding(
                            get: { schedule.startHour },
                            set: { newValue in
                                mutableSchedule.startHour = newValue
                                Task { await adminVM.updateScheduleDay(mutableSchedule) }
                            }
                        )) {
                            ForEach(6..<24, id: \.self) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppTheme.accent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("End")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textMuted)
                        Picker("End", selection: Binding(
                            get: { schedule.endHour },
                            set: { newValue in
                                mutableSchedule.endHour = newValue
                                Task { await adminVM.updateScheduleDay(mutableSchedule) }
                            }
                        )) {
                            ForEach((schedule.startHour + 1)...24, id: \.self) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppTheme.accent)
                    }

                    Spacer()
                }
            }
        }
        .cardStyle()
        .opacity(schedule.isActive ? 1.0 : 0.6)
    }

    private func formatHour(_ hour: Int) -> String {
        if hour == 0 || hour == 24 { return "12 AM" }
        if hour == 12 { return "12 PM" }
        if hour < 12 { return "\(hour) AM" }
        return "\(hour - 12) PM"
    }
}
