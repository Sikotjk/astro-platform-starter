import { motion } from 'framer-motion';
import { FileText, Download, Target, TrendingUp } from 'lucide-react';
import { BarChart } from '../charts/BarChart';
import { DonutChart } from '../charts/DonutChart';
import { ProgressBar } from '../ui/ProgressBar';
import { Button } from '../ui/Button';
import { monthly, allocation, kpis } from '../../lib/data';
import { formatEuro, formatEuroCompact } from '../../lib/format';

const REPORTS = [
    { name: 'Monatsbericht Mai 2026', size: '1,8 MB', type: 'PDF', date: 'Mai 2026' },
    { name: 'Monatsbericht April 2026', size: '1,6 MB', type: 'PDF', date: 'Apr 2026' },
    { name: 'Quartalsbericht Q1 2026', size: '3,2 MB', type: 'PDF', date: 'Q1 2026' },
    { name: 'Mitglieder-Export', size: '240 KB', type: 'CSV', date: 'Jun 2026' },
    { name: 'Prüfbericht extern', size: '2,1 MB', type: 'PDF', date: 'Q1 2026' }
];

const ANNUAL_TARGET = 720000;

function downloadStub(name: string) {
    const blob = new Blob([`${name}\n\nMeridian Fund — generierter Beispielbericht.\n`], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = name.replace(/\s+/g, '_') + '.txt';
    a.click();
    URL.revokeObjectURL(url);
}

export function ReportsView() {
    const bar = monthly.slice(-8).map((m) => ({ label: m.m, a: m.inflow, b: m.outflow }));
    const goalPct = (kpis.totalVolume / ANNUAL_TARGET) * 100;

    return (
        <div className="space-y-5">
            <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
                <motion.div
                    initial={{ opacity: 0, y: 14 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="card-premium p-5 lg:col-span-2"
                >
                    <div className="flex items-center justify-between">
                        <div>
                            <h3 className="text-[15px] font-semibold">Jahresziel</h3>
                            <p className="mt-0.5 text-[13px] text-muted">Fondsvolumen 2026</p>
                        </div>
                        <span className="flex size-10 items-center justify-center rounded-xl bg-primary/12 text-primary">
                            <Target size={18} />
                        </span>
                    </div>
                    <div className="mt-5 flex items-end justify-between">
                        <span className="text-3xl font-bold tracking-tight">{formatEuroCompact(kpis.totalVolume)}</span>
                        <span className="text-[13px] text-muted">Ziel {formatEuroCompact(ANNUAL_TARGET)}</span>
                    </div>
                    <div className="mt-3">
                        <ProgressBar value={goalPct} />
                    </div>
                    <p className="mt-2 text-[13px] text-success">
                        <TrendingUp size={13} className="mr-1 inline" />
                        {goalPct.toFixed(0)}% erreicht — {formatEuro(ANNUAL_TARGET - kpis.totalVolume)} verbleibend
                    </p>
                </motion.div>

                <motion.div
                    initial={{ opacity: 0, y: 14 }}
                    animate={{ opacity: 1, y: 0, transition: { delay: 0.08 } }}
                    className="card-premium p-5"
                >
                    <h3 className="text-[15px] font-semibold">Mittelverwendung</h3>
                    <div className="mt-4">
                        <DonutChart data={allocation} size={150} />
                    </div>
                </motion.div>
            </div>

            <motion.div initial={{ opacity: 0, y: 14 }} animate={{ opacity: 1, y: 0, transition: { delay: 0.12 } }} className="card-premium p-5">
                <h3 className="text-[15px] font-semibold">Zu- & Abfluss im Zeitverlauf</h3>
                <p className="mt-0.5 text-[13px] text-muted">Beiträge vs. Auszahlungen je Monat</p>
                <div className="mt-4">
                    <BarChart data={bar} height={220} />
                </div>
            </motion.div>

            <div className="card-premium">
                <div className="border-b border-border p-5">
                    <h3 className="text-[15px] font-semibold">Verfügbare Berichte</h3>
                    <p className="mt-0.5 text-[13px] text-muted">Automatisch erstellte Exporte zum Herunterladen</p>
                </div>
                <div className="divide-y divide-border">
                    {REPORTS.map((r, i) => (
                        <motion.div
                            key={r.name}
                            initial={{ opacity: 0, x: -8 }}
                            animate={{ opacity: 1, x: 0, transition: { delay: i * 0.05 } }}
                            className="flex items-center gap-4 px-5 py-3.5 transition-colors hover:bg-foreground/[0.03]"
                        >
                            <span className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                <FileText size={18} />
                            </span>
                            <div className="min-w-0 flex-1">
                                <div className="truncate font-medium">{r.name}</div>
                                <div className="text-[12px] text-subtle">
                                    {r.type} · {r.size} · {r.date}
                                </div>
                            </div>
                            <Button variant="ghost" size="sm" onClick={() => downloadStub(r.name)}>
                                <Download size={15} /> Laden
                            </Button>
                        </motion.div>
                    ))}
                </div>
            </div>
        </div>
    );
}
